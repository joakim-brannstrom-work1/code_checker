/**
Copyright: Copyright (c) 2018, Joakim Brännström. All rights reserved.
License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
Author: Joakim Brännström (joakim.brannstrom@gmx.com)

Normal appliation mode.
*/
module app_normal;

import std.algorithm : among;
import std.exception : collectException;
import logger = std.experimental.logger;

import code_checker.cli : Config;
import code_checker.compile_db : CompileCommandDB;
import code_checker.types : AbsolutePath, Path, AbsoluteFileName;

immutable compileCommandsFile = "compile_commands.json";

int modeNormal(ref Config conf) {
    auto fsm = NormalFSM(conf);
    return fsm.run;
}

private:

/** FSM for the control flow when in normal mode.
 */
struct NormalFSM {
    enum State {
        init_,
        changeWorkDir,
        checkForDb,
        genDb,
        checkGenDb,
        fixDb,
        checkFixDb,
        runRegistry,
        cleanup,
        done,
    }

    struct StateData {
        int exitStatus;
        bool hasGenerateDbCommand;
        bool hasCompileDbs;
    }

    State st;
    Config conf;
    bool removeCompileDb;
    /// Root directory from which the program where initially started.
    AbsolutePath root;
    /// Exit status of used to indicate the success to the user.
    int exitStatus;

    this(Config conf) {
        this.conf = conf;
    }

    int run() {
        StateData d;
        d.hasGenerateDbCommand = conf.compileDb.generateDb.length != 0;
        d.hasCompileDbs = conf.compileDb.dbs.length != 0;

        while (st != State.done) {
            debug logger.tracef("state: %s data: %s", st, d);

            st = next(st, d);
            action(st);

            // sync with changed struct members as needed
            d.exitStatus = exitStatus;
        }

        return d.exitStatus;
    }

    /** The next state is calculated. Only dependent on current state and state data.
     *
     * These clean depenencies should make it easier to reason about the flow.
     */
    static State next(const State curr, const StateData d) {
        State next_ = curr;

        final switch (curr) {
        case State.init_:
            next_ = State.changeWorkDir;
            break;
        case State.changeWorkDir:
            next_ = State.checkForDb;
            break;
        case State.checkForDb:
            next_ = State.fixDb;
            if (d.hasGenerateDbCommand)
                next_ = State.genDb;
            break;
        case State.genDb:
            next_ = State.checkGenDb;
            break;
        case State.checkGenDb:
            next_ = State.fixDb;
            if (d.exitStatus != 0)
                next_ = State.cleanup;
            else if (d.hasCompileDbs)
                next_ = State.fixDb;
            break;
        case State.fixDb:
            next_ = State.checkFixDb;
            break;
        case State.checkFixDb:
            next_ = State.runRegistry;
            if (d.exitStatus != 0)
                next_ = State.cleanup;
            break;
        case State.runRegistry:
            next_ = State.cleanup;
            break;
        case State.cleanup:
            next_ = State.done;
            break;
        case State.done:
            break;
        }

        return next_;
    }

    void act_changeWorkDir() {
        import std.file : getcwd, chdir;

        root = Path(getcwd).AbsolutePath;
        if (conf.workDir != root)
            chdir(conf.workDir);
    }

    void act_checkForDb() {
        import std.file : exists;

        removeCompileDb = !exists(compileCommandsFile) && !conf.compileDb.keep;
    }

    void act_genDb() {
        import std.process : spawnShell, wait;

        auto res = spawnShell(conf.compileDb.generateDb).wait;
        if (res != 0) {
            logger.error("Failed running command to generate the compile_commands.json");
            exitStatus = 1;
        }
    }

    void act_fixDb() {
        import std.algorithm : map;
        import std.array : appender, array;
        import std.stdio : File;
        import code_checker.compile_db : fromArgCompileDb;

        logger.trace("Creating a unified compile_commands.json");

        auto compile_db = appender!string();
        try {
            auto dbs = findCompileDbs(conf.compileDb.dbs);
            if (dbs.length == 0) {
                logger.errorf("No %s found in %s", compileCommandsFile, conf.compileDb.dbs);
                exitStatus = 1;
                return;
            }

            auto db = fromArgCompileDb(dbs.map!(a => cast(string) a.dup).array);
            unifyCompileDb(db, compile_db);
            File(compileCommandsFile, "w").write(compile_db.data);
        } catch (Exception e) {
            logger.errorf("Unable to process %s", compileCommandsFile);
            logger.error(e.msg);
            exitStatus = 1;
        }
    }

    void act_runRegistry() {
        import std.algorithm : map;
        import std.array : array;
        import code_checker.engine;
        import code_checker.compile_db : fromArgCompileDb, parseFlag,
            CompileCommandFilter;

        Environment env;
        env.compileDbFile = AbsolutePath(Path(compileCommandsFile));
        env.compileDb = fromArgCompileDb([env.compileDbFile]);
        env.files = () {
            if (conf.analyzeFiles.length == 0)
                return env.files = env.compileDb.map!(a => cast(string) a.absoluteFile.payload)
                    .array;
            else
                        return conf.analyzeFiles.dup;
        }();
        env.genCompileDb = conf.compileDb.generateDb;
        env.staticCode = conf.staticCode;
        env.clangTidy = conf.clangTidy;
        env.compiler = conf.compiler;

        Registry reg;
        reg.put(new ClangTidy, Type.staticCode);
        exitStatus = execute(env, reg) == Status.passed ? 0 : 1;
    }

    void act_cleanup() {
        import std.file : remove, chdir;

        if (removeCompileDb)
            remove(compileCommandsFile).collectException;

        chdir(root);
    }

    /// Generate a callback for each state.
    void action(const State st) {
        string genCallAction() {
            import std.format : format;
            import std.traits : EnumMembers;

            string s;
            s ~= "final switch(st) {";
            static foreach (a; EnumMembers!State) {
                {
                    const actfn = format("act_%s", a);
                    static if (__traits(hasMember, NormalFSM, actfn))
                        s ~= format("case State.%s: %s();break;", a, actfn);
                    else {
                        pragma(msg, __FILE__ ~ ": no callback found: " ~ actfn);
                        s ~= format("case State.%s: break;", a);
                    }
                }
            }
            s ~= "}";
            return s;
        }

        mixin(genCallAction);
    }
}

auto findCompileDbs(const(AbsolutePath)[] paths) nothrow {
    import std.algorithm : filter, map;
    import std.file : exists, isDir, isFile, dirEntries, SpanMode;

    AbsolutePath[] rval;

    static AbsolutePath[] findRecursive(const AbsolutePath p) {
        import std.path : baseName;

        AbsolutePath[] rval;
        foreach (a; dirEntries(p, SpanMode.depth).filter!(a => a.isFile)
                .filter!(a => a.name.baseName == compileCommandsFile).map!(a => a.name)) {
            try {
                rval ~= AbsolutePath(Path(a));
            } catch (Exception e) {
                logger.warning(e.msg);
            }
        }
        return rval;
    }

    foreach (a; paths.filter!(a => exists(a))) {
        try {
            if (a.isDir) {
                logger.tracef("Looking for compilation database in '%s'", a).collectException;
                rval ~= findRecursive(a);
            } else if (a.isFile)
                rval ~= a;
        } catch (Exception e) {
            logger.warning(e.msg).collectException;
        }
    }

    return rval;
}

/// Unify multiple compilation databases to one json file.
void unifyCompileDb(AppT)(CompileCommandDB db, ref AppT app) {
    import std.algorithm : map, joiner, filter, copy;
    import std.array : array, appender;
    import std.ascii : newline;
    import std.format : formattedWrite;
    import std.json : JSONValue;
    import std.path : stripExtension;
    import std.range : put;
    import code_checker.compile_db;

    auto flag_filter = CompileCommandFilter(defaultCompilerFilter.filter.dup, 0);
    logger.trace(flag_filter);

    void writeEntry(T)(ref const T e) {
        import std.exception : assumeUnique;
        import std.utf : byChar;

        auto raw_flags = () @safe{
            auto app = appender!(string[]);
            e.parseFlag(flag_filter).flags.copy(app);
            // add back dummy -c otherwise clang-tidy do not work
            ["-c", cast(string) e.absoluteFile].copy(app);
            return app.data;
        }();

        formattedWrite(app, `"directory": "%s",`, cast(string) e.directory);

        if (e.arguments.hasValue) {
            formattedWrite(app, `"arguments": %s,`, raw_flags);
        } else {
            formattedWrite(app, `"command": "%-(%s %)",`, raw_flags);
        }

        if (e.output.hasValue)
            formattedWrite(app, `"output": "%s",`, cast(string) e.absoluteOutput);
        formattedWrite(app, `"file": "%s"`, cast(string) e.absoluteFile);
    }

    if (db.length == 0) {
        return;
    }

    formattedWrite(app, "[");

    foreach (ref const e; db[0 .. $ - 1]) {
        formattedWrite(app, "{");
        writeEntry(e);
        formattedWrite(app, "},");
        put(app, newline);
    }

    formattedWrite(app, "{");
    writeEntry(db[$ - 1]);
    formattedWrite(app, "}");

    formattedWrite(app, "]");
}
