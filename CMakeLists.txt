cmake_minimum_required(VERSION 3.20)
project(trezor_lib C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Where upstream code lives (from sparse checkout)
set(TREZOR_CRYPTO_DIR "${CMAKE_CURRENT_LIST_DIR}/trezor-crypto")
set(TREZOR_INC_DIR    "${TREZOR_CRYPTO_DIR}/include")
set(TREZOR_SRC_DIR    "${TREZOR_CRYPTO_DIR}/crypto")

# ---- Minimal set for what you described (base58/bip39/pbkdf2/sha2/ripemd160 + hasher) ----
# NOTE: hasher.c references multiple algorithms depending on HasherType you use.
# To keep it "drop-in" compatible with base58_decode_check(HASHER_SHA2D) and
# avoid undefined symbols, include hasher.c + sha3.c + blake256.c + blake2b.c + groestl.c.
set(TREZOR_SOURCES
    "${TREZOR_SRC_DIR}/memzero.c"
    "${TREZOR_SRC_DIR}/sha2.c"
    "${TREZOR_SRC_DIR}/hmac.c"
    "${TREZOR_SRC_DIR}/pbkdf2.c"
    "${TREZOR_SRC_DIR}/ripemd160.c"
    "${TREZOR_SRC_DIR}/base58.c"
    "${TREZOR_SRC_DIR}/bip39.c"

    # hasher + deps (upstream only, no custom file)
    "${TREZOR_SRC_DIR}/hasher.c"
    "${TREZOR_SRC_DIR}/sha3.c"     # keccak256
    "${TREZOR_SRC_DIR}/blake256.c"
    "${TREZOR_SRC_DIR}/blake2b.c"
    "${TREZOR_SRC_DIR}/groestl.c"

    "${TREZOR_SRC_DIR}/bip32.c"    # derive m/44'/60'/0'/0/0
    "${TREZOR_SRC_DIR}/bignum.c"
    "${TREZOR_SRC_DIR}/ecdsa.c"
    "${TREZOR_SRC_DIR}/curves.c"
)

add_library(TrezorCrypto STATIC ${TREZOR_SOURCES})
target_include_directories(TrezorCrypto PUBLIC "${TREZOR_INC_DIR}")

# Performance-ish defaults for Release.
# (You can also pass -DCMAKE_C_FLAGS_RELEASE=... from the command line.)
target_compile_definitions(TrezorCrypto PRIVATE NDEBUG=1)
target_compile_options(TrezorCrypto PRIVATE
    -O3
    -fvisibility=hidden
    -ffunction-sections 
    -fdata-sections
)

# If you never use HASHER_SHA3K / keccak, you can force it off:
target_compile_definitions(TrezorCrypto PRIVATE USE_KECCAK=1)
set_property(TARGET TrezorCrypto PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)
set_target_properties(TrezorCrypto PROPERTIES OUTPUT_NAME "TrezorCrypto")

include(GNUInstallDirs)
install(TARGETS TrezorCrypto ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}")
install(DIRECTORY "${TREZOR_INC_DIR}/" DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

