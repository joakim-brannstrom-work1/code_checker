/**
Copyright: Copyright (c) 2018, Joakim Brännström. All rights reserved.
License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
Author: Joakim Brännström (joakim.brannstrom@gmx.com)
*/
module code_checker.engine.builtin.clang_tidy_classification;

@safe:

enum Severity {
    style,
    low,
    medium,
    high,
    critical
}

immutable Severity[string] severityMap;

shared static this() {
    // copied from https://github.com/Ericsson/codechecker/blob/master/config/checker_severity_map.json

    // sorted alphabetically

    // dfmt off
    severityMap = [
    "alpha.clone.CloneChecker":                                   Severity.low,
    "alpha.core.BoolAssignment":                                  Severity.low,
    "alpha.core.CallAndMessageUnInitRefArg":                      Severity.high,
    "alpha.core.CastSize":                                        Severity.low,
    "alpha.core.CastToStruct":                                    Severity.low,
    "alpha.core.Conversion":                                      Severity.low,
    "alpha.core.FixedAddr":                                       Severity.low,
    "alpha.core.IdenticalExpr":                                   Severity.low,
    "alpha.core.PointerArithm":                                   Severity.low,
    "alpha.core.PointerSub":                                      Severity.low,
    "alpha.core.SizeofPtr":                                       Severity.low,
    "alpha.core.TestAfterDivZero":                                Severity.medium,
    "alpha.cplusplus.DeleteWithNonVirtualDtor":                   Severity.high,
    "alpha.cplusplus.IteratorRange":                              Severity.medium,
    "alpha.cplusplus.MisusedMovedObject":                         Severity.medium,
    "alpha.deadcode.UnreachableCode":                             Severity.low,
    "alpha.osx.cocoa.DirectIvarAssignment":                       Severity.low,
    "alpha.osx.cocoa.DirectIvarAssignmentForAnnotatedFunctions":  Severity.low,
    "alpha.osx.cocoa.InstanceVariableInvalidation":               Severity.low,
    "alpha.osx.cocoa.MissingInvalidationMethod":                  Severity.low,
    "alpha.osx.cocoa.localizability.PluralMisuseChecker":         Severity.low,
    "alpha.security.ArrayBound":                                  Severity.high,
    "alpha.security.ArrayBoundV2":                                Severity.high,
    "alpha.security.MallocOverflow":                              Severity.high,
    "alpha.security.ReturnPtrRange":                              Severity.low,
    "alpha.unix.BlockInCriticalSection":                          Severity.low,
    "alpha.unix.Chroot":                                          Severity.medium,
    "alpha.unix.PthreadLock":                                     Severity.high,
    "alpha.unix.SimpleStream":                                    Severity.medium,
    "alpha.unix.Stream":                                          Severity.medium,
    "alpha.unix.cstring.BufferOverlap":                           Severity.high,
    "alpha.unix.cstring.NotNullTerminated":                       Severity.high,
    "alpha.unix.cstring.OutOfBounds":                             Severity.high,
    "android-cloexec-creat":                                      Severity.medium,
    "android-cloexec-fopen":                                      Severity.medium,
    "android-cloexec-open":                                       Severity.medium,
    "android-cloexec-socket":                                     Severity.medium,
    "boost-use-to-string":                                        Severity.low,
    "bugprone-argument-comment":                                  Severity.low,
    "bugprone-assert-side-effect":                                Severity.medium,
    "bugprone-bool-pointer-implicit-conversion":                  Severity.low,
    "bugprone-copy-constructor-init":                             Severity.medium,
    "bugprone-dangling-handle":                                   Severity.high,
    "bugprone-fold-init-type":                                    Severity.high,
    "bugprone-forward-declaration-namespace":                     Severity.low,
    "bugprone-inaccurate-erase":                                  Severity.high,
    "bugprone-integer-division":                                  Severity.medium,
    "bugprone-misplaced-operator-in-strlen-in-alloc":             Severity.medium,
    "bugprone-misplaced-operator-in-strlen-in-alloc":             Severity.medium,
    "bugprone-move-forwarding-reference":                         Severity.medium,
    "bugprone-multiple-statement-macro":                          Severity.medium,
    "bugprone-string-constructor":                                Severity.high,
    "bugprone-suspicious-memset-usage":                           Severity.high,
    "bugprone-undefined-memory-manipulation":                     Severity.medium,
    "bugprone-use-after-move":                                    Severity.high,
    "bugprone-virtual-near-miss":                                 Severity.medium,
    "cert-dcl03-c":                                               Severity.medium,
    "cert-dcl21-cpp":                                             Severity.low,
    "cert-dcl50-cpp":                                             Severity.low,
    "cert-dcl54-cpp":                                             Severity.medium,
    "cert-dcl58-cpp":                                             Severity.high,
    "cert-dcl59-cpp":                                             Severity.medium,
    "cert-env33-c":                                               Severity.medium,
    "cert-err09-cpp":                                             Severity.high,
    "cert-err34-c":                                               Severity.low,
    "cert-err52-cpp":                                             Severity.low,
    "cert-err58-cpp":                                             Severity.low,
    "cert-err60-cpp":                                             Severity.medium,
    "cert-err61-cpp":                                             Severity.high,
    "cert-fio38-c":                                               Severity.high,
    "cert-flp30-c":                                               Severity.high,
    "cert-msc30-c":                                               Severity.low,
    "cert-msc50-cpp":                                             Severity.low,
    "cert-oop11-cpp":                                             Severity.medium,
    "core.CallAndMessage":                                        Severity.high,
    "core.DivideZero":                                            Severity.high,
    "core.DynamicTypePropagation":                                Severity.medium,
    "core.NonNullParamChecker":                                   Severity.high,
    "core.NullDereference":                                       Severity.high,
    "core.StackAddressEscape":                                    Severity.high,
    "core.UndefinedBinaryOperatorResult":                         Severity.medium,
    "core.VLASize":                                               Severity.medium,
    "core.builtin.BuiltinFunctions":                              Severity.medium,
    "core.builtin.NoReturnFunctions":                             Severity.medium,
    "core.uninitialized.ArraySubscript":                          Severity.medium,
    "core.uninitialized.Assign":                                  Severity.medium,
    "core.uninitialized.Branch":                                  Severity.medium,
    "core.uninitialized.CapturedBlockVariable":                   Severity.medium,
    "core.uninitialized.UndefReturn":                             Severity.high,
    "cplusplus.NewDelete":                                        Severity.high,
    "cplusplus.NewDeleteLeaks":                                   Severity.high,
    "cplusplus.SelfAssignment":                                   Severity.medium,
    "cppcoreguidelines-c-copy-assignment-signature":              Severity.medium,
    "cppcoreguidelines-interfaces-global-init":                   Severity.low,
    "cppcoreguidelines-no-malloc":                                Severity.low,
    "cppcoreguidelines-pro-bounds-array-to-pointer-decay":        Severity.low,
    "cppcoreguidelines-pro-bounds-constant-array-index":          Severity.low,
    "cppcoreguidelines-pro-bounds-pointer-arithmetic":            Severity.low,
    "cppcoreguidelines-pro-type-const-cast":                      Severity.low,
    "cppcoreguidelines-pro-type-cstyle-cast":                     Severity.low,
    "cppcoreguidelines-pro-type-member-init":                     Severity.low,
    "cppcoreguidelines-pro-type-reinterpret-cast":                Severity.low,
    "cppcoreguidelines-pro-type-static-cast-downcast":            Severity.low,
    "cppcoreguidelines-pro-type-union-access":                    Severity.low,
    "cppcoreguidelines-pro-type-vararg":                          Severity.low,
    "cppcoreguidelines-slicing":                                  Severity.low,
    "cppcoreguidelines-special-member-functions":                 Severity.low,
    "deadcode.DeadStores":                                        Severity.low,
    "google-build-explicit-make-pair":                            Severity.medium,
    "google-build-namespaces":                                    Severity.medium,
    "google-build-using-namespace":                               Severity.style,
    "google-default-arguments":                                   Severity.low,
    "google-explicit-constructor":                                Severity.medium,
    "google-global-names-in-headers":                             Severity.high,
    "google-readability-braces-around-statements":                Severity.style,
    "google-readability-casting":                                 Severity.low,
    "google-readability-function-size":                           Severity.style,
    "google-readability-namespace-comments":                      Severity.style,
    "google-readability-redundant-smartptr-get":                  Severity.medium,
    "google-readability-todo":                                    Severity.style,
    "google-runtime-int":                                         Severity.low,
    "google-runtime-member-string-references":                    Severity.low,
    "google-runtime-memset":                                      Severity.high,
    "google-runtime-operator":                                    Severity.medium,
    "hicpp-braces-around-statements":                             Severity.style,
    "hicpp-deprecated-headers":                                   Severity.low,
    "hicpp-exception-baseclass":                                  Severity.low,
    "hicpp-explicit-conversions":                                 Severity.low,
    "hicpp-function-size":                                        Severity.low,
    "hicpp-invalid-access-moved":                                 Severity.high,
    "hicpp-member-init":                                          Severity.low,
    "hicpp-move-const-arg":                                       Severity.medium,
    "hicpp-named-parameter":                                      Severity.low,
    "hicpp-new-delete-operators":                                 Severity.low,
    "hicpp-no-array-decay":                                       Severity.low,
    "hicpp-no-assembler":                                         Severity.low,
    "hicpp-no-malloc":                                            Severity.low,
    "hicpp-noexcept-move":                                        Severity.medium,
    "hicpp-signed-bitwise":                                       Severity.low,
    "hicpp-special-member-functions":                             Severity.low,
    "hicpp-static-assert":                                        Severity.low,
    "hicpp-undelegated-constructor":                              Severity.medium,
    "hicpp-use-auto":                                             Severity.style,
    "hicpp-use-emplace":                                          Severity.style,
    "hicpp-use-equals-default":                                   Severity.low,
    "hicpp-use-equals-delete":                                    Severity.low,
    "hicpp-use-noexcept":                                         Severity.style,
    "hicpp-use-nullptr":                                          Severity.low,
    "hicpp-use-override":                                         Severity.low,
    "hicpp-vararg":                                               Severity.low,
    "llvm-header-guard":                                          Severity.low,
    "llvm-include-order":                                         Severity.low,
    "llvm-namespace-comment":                                     Severity.low,
    "llvm-twine-local":                                           Severity.low,
    "llvm.Conventions":                                           Severity.low,
    "misc-argument-comment":                                      Severity.low,
    "misc-assert-side-effect":                                    Severity.medium,
    "misc-bool-pointer-implicit-conversion":                      Severity.low,
    "misc-dangling-handle":                                       Severity.high,
    "misc-definitions-in-headers":                                Severity.medium,
    "misc-fold-init-type":                                        Severity.high,
    "misc-forward-declaration-namespace":                         Severity.low,
    "misc-forwarding-reference-overload":                         Severity.low,
    "misc-inaccurate-erase":                                      Severity.high,
    "misc-incorrect-roundings":                                   Severity.high,
    "misc-inefficient-algorithm":                                 Severity.medium,
    "misc-lambda-function-name":                                  Severity.low,
    "misc-macro-parentheses":                                     Severity.medium,
    "misc-macro-repeated-side-effects":                           Severity.medium,
    "misc-misplaced-const":                                       Severity.low,
    "misc-misplaced-widening-cast":                               Severity.high,
    "misc-move-const-arg":                                        Severity.medium,
    "misc-move-constructor-init":                                 Severity.medium,
    "misc-move-forwarding-reference":                             Severity.medium,
    "misc-multiple-statement-macro":                              Severity.medium,
    "misc-new-delete-overloads":                                  Severity.medium,
    "misc-noexcept-move-constructor":                             Severity.medium,
    "misc-non-copyable-objects":                                  Severity.high,
    "misc-redundant-expression":                                  Severity.medium,
    "misc-sizeof-container":                                      Severity.high,
    "misc-sizeof-expression":                                     Severity.high,
    "misc-static-assert":                                         Severity.low,
    "misc-string-compare":                                        Severity.low,
    "misc-string-constructor":                                    Severity.high,
    "misc-string-integer-assignment":                             Severity.low,
    "misc-string-literal-with-embedded-nul":                      Severity.medium,
    "misc-suspicious-enum-usage":                                 Severity.high,
    "misc-suspicious-missing-comma":                              Severity.high,
    "misc-suspicious-semicolon":                                  Severity.high,
    "misc-suspicious-string-compare":                             Severity.medium,
    "misc-swapped-arguments":                                     Severity.high,
    "misc-throw-by-value-catch-by-reference":                     Severity.high,
    "misc-unconventional-assign-operator":                        Severity.medium,
    "misc-undelegated-constructor":                               Severity.medium,
    "misc-uniqueptr-reset-release":                               Severity.medium,
    "misc-unused-alias-decls":                                    Severity.low,
    "misc-unused-parameters":                                     Severity.low,
    "misc-unused-raii":                                           Severity.high,
    "misc-unused-using-decls":                                    Severity.low,
    "misc-use-after-move":                                        Severity.high,
    "misc-virtual-near-miss":                                     Severity.high,
    "modernize-avoid-bind":                                       Severity.style,
    "modernize-deprecated-headers":                               Severity.low,
    "modernize-loop-convert":                                     Severity.style,
    "modernize-make-shared":                                      Severity.low,
    "modernize-make-unique":                                      Severity.low,
    "modernize-pass-by-value":                                    Severity.low,
    "modernize-raw-string-literal":                               Severity.style,
    "modernize-redundant-void-arg":                               Severity.style,
    "modernize-replace-auto-ptr":                                 Severity.low,
    "modernize-replace-random-shuffle":                           Severity.low,
    "modernize-return-braced-init-list":                          Severity.style,
    "modernize-shrink-to-fit":                                    Severity.style,
    "modernize-unary-static-assert":                              Severity.style,
    "modernize-use-auto":                                         Severity.style,
    "modernize-use-bool-literals":                                Severity.style,
    "modernize-use-default-member-init":                          Severity.style,
    "modernize-use-emplace":                                      Severity.style,
    "modernize-use-equals-default":                               Severity.style,
    "modernize-use-equals-delete":                                Severity.style,
    "modernize-use-noexcept":                                     Severity.style,
    "modernize-use-nullptr":                                      Severity.low,
    "modernize-use-override":                                     Severity.low,
    "modernize-use-transparent-functors":                         Severity.low,
    "modernize-use-using":                                        Severity.style,
    "mpi-buffer-deref":                                           Severity.low,
    "mpi-type-mismatch":                                          Severity.low,
    "nullability.NullPassedToNonnull":                            Severity.high,
    "nullability.NullReturnedFromNonnull":                        Severity.high,
    "nullability.NullableDereferenced":                           Severity.medium,
    "nullability.NullablePassedToNonnull":                        Severity.medium,
    "nullability.NullableReturnedFromNonnull":                    Severity.medium,
    "optin.cplusplus.VirtualCall":                                Severity.medium,
    "optin.mpi.MPI-Checker":                                      Severity.medium,
    "optin.performance.Padding":                                  Severity.low,
    "optin.portability.UnixAPI":                                  Severity.medium,
    "performance-faster-string-find":                             Severity.low,
    "performance-for-range-copy":                                 Severity.low,
    "performance-implicit-cast-in-loop":                          Severity.low,
    "performance-implicit-conversion-in-loop":                    Severity.low,
    "performance-inefficient-algorithm":                          Severity.medium,
    "performance-inefficient-string-concatenation":               Severity.low,
    "performance-inefficient-vector-operation":                   Severity.low,
    "performance-move-const-arg":                                 Severity.medium,
    "performance-move-constructor-init":                          Severity.medium,
    "performance-noexcept-move-constructor":                      Severity.medium,
    "performance-type-promotion-in-math-fn":                      Severity.low,
    "performance-unnecessary-copy-initialization":                Severity.low,
    "performance-unnecessary-value-param":                        Severity.low,
    "readability-avoid-const-params-in-decls":                    Severity.style,
    "readability-braces-around-statements":                       Severity.style,
    "readability-container-size-empty":                           Severity.style,
    "readability-delete-null-pointer":                            Severity.style,
    "readability-deleted-default":                                Severity.style,
    "readability-else-after-return":                              Severity.style,
    "readability-function-size":                                  Severity.style,
    "readability-identifier-naming":                              Severity.style,
    "readability-implicit-bool-cast":                             Severity.style,
    "readability-implicit-bool-conversion":                       Severity.style,
    "readability-inconsistent-declaration-parameter-name":        Severity.style,
    "readability-misleading-indentation":                         Severity.low,
    "readability-misplaced-array-index":                          Severity.style,
    "readability-named-parameter":                                Severity.style,
    "readability-non-const-parameter":                            Severity.style,
    "readability-redundant-control-flow":                         Severity.style,
    "readability-redundant-declaration":                          Severity.style,
    "readability-redundant-function-ptr-dereference":             Severity.style,
    "readability-redundant-member-init":                          Severity.style,
    "readability-redundant-smartptr-get":                         Severity.style,
    "readability-redundant-string-cstr":                          Severity.style,
    "readability-redundant-string-init":                          Severity.style,
    "readability-simplify-boolean-expr":                          Severity.medium,
    "readability-static-accessed-through-instance":               Severity.style,
    "readability-static-definition-in-anonymous-namespace":       Severity.style,
    "readability-uniqueptr-delete-release":                       Severity.style,
    "security.FloatLoopCounter":                                  Severity.medium,
    "security.insecureAPI.UncheckedReturn":                       Severity.medium,
    "security.insecureAPI.getpw":                                 Severity.medium,
    "security.insecureAPI.gets":                                  Severity.medium,
    "security.insecureAPI.mkstemp":                               Severity.medium,
    "security.insecureAPI.mktemp":                                Severity.medium,
    "security.insecureAPI.rand":                                  Severity.medium,
    "security.insecureAPI.strcpy":                                Severity.medium,
    "security.insecureAPI.vfork":                                 Severity.medium,
    "unix.API":                                                   Severity.medium,
    "unix.Malloc":                                                Severity.medium,
    "unix.MallocSizeof":                                          Severity.medium,
    "unix.MismatchedDeallocator":                                 Severity.medium,
    "unix.Vfork":                                                 Severity.medium,
    "unix.cstring.BadSizeArg":                                    Severity.medium,
    "unix.cstring.NullArg":                                       Severity.medium,
    "valist.CopyToSelf":                                          Severity.medium,
    "valist.Uninitialized":                                       Severity.medium,
    "valist.Unterminated":                                        Severity.medium,
            ];
    // dfmt on
}
