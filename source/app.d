/**
Copyright: Copyright (c) 2018, Joakim Brännström. All rights reserved.
License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
Author: Joakim Brännström (joakim.brannstrom@gmx.com)
*/
module app;

import std.algorithm : among;
import std.exception : collectException;

import logger = std.experimental.logger;
import code_checker.types : AbsolutePath, Path;

immutable compileCommandsFile = "compile_commands.json";

int main(string[] args) {
    import std.functional : toDelegate;
    import code_checker.logger;

    Config conf;
    parseCLI(args, conf);
    confLogger(conf.verbose);
    logger.trace(conf);

    alias Command = int delegate(const ref Config conf);
    Command[AppMode] cmds;
    cmds[AppMode.none] = toDelegate(&modeNone);
    cmds[AppMode.help] = toDelegate(&modeNone);
    cmds[AppMode.helpUnknownCommand] = toDelegate(&modeNone_Error);
    cmds[AppMode.normal] = toDelegate(&modeNormal);

    if (auto v = conf.mode in cmds) {
        return (*v)(conf);
    }

    logger.error("Unknown mode %s", conf.mode);
    return 1;
}

int modeNone(const ref Config conf) {
    return 0;
}

int modeNone_Error(const ref Config conf) {
    return 1;
}

int modeNormal(const ref Config conf) {
    import std.array : appender;
    import std.file : exists;
    import std.stdio : File;

    if (!exists(compileCommandsFile)) {
        auto compile_db = appender!string();
        try {
            auto dbs = findCompileDbs(conf.compileDbs);
            if (dbs.length == 0) {
                logger.errorf("No %s found in %s", compileCommandsFile, conf.compileDbs);
                return 1;
            }
            unifyCompileDb(dbs, compile_db);
        } catch (Exception e) {
            logger.error(e.msg);
            return 1;
        }

        File(compileCommandsFile, "w").write(compile_db.data);
    }

    return 0;
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
void unifyCompileDb(AppT)(const(AbsolutePath)[] paths, ref AppT app) {
    import std.algorithm : map, joiner;
    import std.array : array;
    import std.ascii : newline;
    import std.format : formattedWrite;
    import std.range : put;
    import std.json : JSONValue;
    import code_checker.compile_db;

    auto db = fromArgCompileDb(paths.map!(a => cast(string) a.dup).array);
    auto flag_filter = CompileCommandFilter(defaultCompilerFilter.filter.dup, 0);
    logger.trace(flag_filter);

    void writeEntry(T)(ref const T e) {
        import std.exception : assumeUnique;
        import std.utf : byChar;

        string raw_flags = assumeUnique(e.parseFlag(flag_filter).flags.joiner(" ").byChar.array());

        formattedWrite(app, `"directory": "%s",`, cast(string) e.directory);

        if (e.arguments.hasValue) {
            formattedWrite(app, `"command": "g++ %s",`, raw_flags);
            formattedWrite(app, `"arguments": "%s",`, raw_flags);
        } else {
            formattedWrite(app, `"command": "%s",`, raw_flags);
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

enum AppMode {
    none,
    help,
    helpUnknownCommand,
    normal,
}

struct Config {
    import code_checker.logger : VerboseMode;

    AppMode mode;
    VerboseMode verbose;

    /// Either a path to a compilation database or a directory to search for one in.
    AbsolutePath[] compileDbs;
}

void parseCLI(string[] args, ref Config conf) {
    import std.algorithm : map;
    import std.array : array;
    import code_checker.logger : VerboseMode;
    static import std.getopt;

    bool verbose_info;
    bool verbose_trace;
    std.getopt.GetoptResult help_info;
    try {
        string[] compile_dbs;
        // dfmt off
        help_info = std.getopt.getopt(args,
            std.getopt.config.keepEndOfOptions,
            "c|compile-db", "path to a compilationi database or where to search for one", &compile_dbs,
            "v|verbose", "verbose mode is set to information", &verbose_info,
            "vverbose", "verbose mode is set to trace", &verbose_trace,
            );
        // dfmt on
        conf.mode = help_info.helpWanted ? AppMode.help : AppMode.normal;
        conf.verbose = () {
            if (verbose_trace)
                return VerboseMode.trace;
            if (verbose_info)
                return VerboseMode.info;
            return VerboseMode.minimal;
        }();
        conf.compileDbs = compile_dbs.map!(a => Path(a).AbsolutePath).array;
        if (compile_dbs.length == 0)
            conf.compileDbs = [AbsolutePath(Path("."))];
    } catch (std.getopt.GetOptException e) {
        // unknown option
        logger.error(e.msg);
        conf.mode = AppMode.helpUnknownCommand;
    } catch (Exception e) {
        logger.error(e.msg);
        conf.mode = AppMode.helpUnknownCommand;
    }

    void printHelp() {
        import std.getopt : defaultGetoptPrinter;
        import std.format : format;
        import std.path : baseName;

        defaultGetoptPrinter(format("usage: %s\n", args[0].baseName), help_info.options);
    }

    if (conf.mode.among(AppMode.help, AppMode.helpUnknownCommand)) {
        printHelp;
        return;
    }
}
