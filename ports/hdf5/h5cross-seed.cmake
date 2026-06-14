# Cross-compile seed for HDF5's run-time detection on the Android (arm64) triplet.
#
# HDF5's CMake runs TRY_RUN probes for a set of long-double / floating-point
# conversion behaviours and the printf "ll" width / max real precision. Those
# probes execute a compiled target binary, which is impossible when cross-
# compiling for arm64-android. Without a seed, configure stops at the cross-
# compile wall (vcpkg #34824, closed not-planned).
#
# Prepended as the FIRST `-C<initial-cache>` option to vcpkg_cmake_configure
# (Android triplet only), so these INTERNAL cache entries exist before HDF5's
# checks run and the cross-compile guards are satisfied. For each conversion
# probe we seed <VAR>_COMPILE (the probe compiled) and the integer <VAR>_RUN
# (the probe's exit code; 0 == "yes / works"). Values mirror the proven smoke
# record for arm64-android (long double == IEEE-754 double on Bionic). Surplus
# vars not consulted by this HDF5 version are harmlessly ignored.

# Long double <-> integer conversion probes.
set(H5_LDOUBLE_TO_LONG_SPECIAL_COMPILE   TRUE CACHE INTERNAL "")
set(H5_LDOUBLE_TO_LONG_SPECIAL_RUN       1    CACHE INTERNAL "")
set(H5_LONG_TO_LDOUBLE_SPECIAL_COMPILE   TRUE CACHE INTERNAL "")
set(H5_LONG_TO_LDOUBLE_SPECIAL_RUN       1    CACHE INTERNAL "")
set(H5_LDOUBLE_TO_LLONG_ACCURATE_COMPILE TRUE CACHE INTERNAL "")
set(H5_LDOUBLE_TO_LLONG_ACCURATE_RUN     0    CACHE INTERNAL "")
set(H5_LLONG_TO_LDOUBLE_CORRECT_COMPILE  TRUE CACHE INTERNAL "")
set(H5_LLONG_TO_LDOUBLE_CORRECT_RUN      0    CACHE INTERNAL "")
set(H5_DISABLE_SOME_LDOUBLE_CONV_COMPILE TRUE CACHE INTERNAL "")
set(H5_DISABLE_SOME_LDOUBLE_CONV_RUN     1    CACHE INTERNAL "")

# Alignment / floating-point -> integer conversion probes.
set(H5_NO_ALIGNMENT_RESTRICTIONS_COMPILE TRUE CACHE INTERNAL "")
set(H5_NO_ALIGNMENT_RESTRICTIONS_RUN     0    CACHE INTERNAL "")
set(H5_FP_TO_INTEGER_OVERFLOW_WORKS_COMPILE TRUE CACHE INTERNAL "")
set(H5_FP_TO_INTEGER_OVERFLOW_WORKS_RUN     0 CACHE INTERNAL "")
set(H5_FP_TO_ULLONG_ACCURATE_COMPILE     TRUE CACHE INTERNAL "")
set(H5_FP_TO_ULLONG_ACCURATE_RUN         0    CACHE INTERNAL "")
set(H5_FP_TO_ULLONG_RIGHT_MAXIMUM_COMPILE TRUE CACHE INTERNAL "")
set(H5_FP_TO_ULLONG_RIGHT_MAXIMUM_RUN    0    CACHE INTERNAL "")
set(H5_ULLONG_TO_FP_CAST_WORKS_COMPILE   TRUE CACHE INTERNAL "")
set(H5_ULLONG_TO_FP_CAST_WORKS_RUN       0    CACHE INTERNAL "")
set(H5_ULLONG_TO_LDOUBLE_PRECISION_COMPILE TRUE CACHE INTERNAL "")
set(H5_ULLONG_TO_LDOUBLE_PRECISION_RUN   0    CACHE INTERNAL "")
set(H5_LDOUBLE_TO_UINT_ACCURATE_COMPILE  TRUE CACHE INTERNAL "")
set(H5_LDOUBLE_TO_UINT_ACCURATE_RUN      0    CACHE INTERNAL "")

# printf "ll" width probe.
set(H5_PRINTF_LL_TEST_COMPILE            TRUE CACHE INTERNAL "")
set(H5_PRINTF_LL_TEST_RUN                0    CACHE INTERNAL "")
set(H5_PRINTF_LL_WIDTH                   "ll" CACHE INTERNAL "")

# Maximum decimal precision for C long double (no __float128 on arm64-android).
set(H5_PAC_C_MAX_REAL_PRECISION          21   CACHE INTERNAL "")
