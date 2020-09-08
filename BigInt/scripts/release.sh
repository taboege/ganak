#!/bin/bash

release_dir="release"
release_file="$release_dir/BigInt.hpp"

# create release directory, if it doesn't exist
mkdir -p "$release_dir"
# remove previous release file, if it exists
rm -f "$release_file"

#read -p "Enter release version: " version

comment="\
/*\n\
    BigInt\n\
    ------\n\
    Arbitrary-sized integer class for C++.\n\
    \n\
    Version: $BIGINT_VERSION\n\
    Released on: $(date +'%d %B %Y %R %Z')\n\
    Author: Syed Faheel Ahmad (faheel@live.in)\n\
    Project on GitHub: https://github.com/faheel/BigInt\n\
    License: MIT\n\
*/\n\n"

printf "$comment" >> "$release_file"

# topologically sorted list of header files
header_files="BigInt.hpp \
    functions/utility.hpp \
    functions/random.hpp \
    constructors/constructors.hpp \
    functions/conversion.hpp \
    operators/assignment.hpp \
    operators/unary_arithmetic.hpp \
    operators/relational.hpp \
    functions/math.hpp \
    operators/binary_arithmetic.hpp \
    operators/arithmetic_assignment.hpp \
    operators/increment_decrement.hpp \
    operators/io_stream.hpp"

# First all #include's, then we open an anonymous namespace to
# prevent multiple definition errors.
for file in $header_files
do
    cat "include/$file" | grep "^#include" >> "$release_file"
done
echo '#pragma GCC diagnostic push' >> "$release_file"
echo '#pragma GCC diagnostic ignored "-Wunused-function"' >> "$release_file"
echo 'namespace {' >> "$release_file"

# append the contents of each header file to the release file,
# except the #include's.
for file in $header_files
do
    cat "include/$file" | grep -v "^#include" >> "$release_file"
    printf "\n\n" >> "$release_file"
done

echo '} /* namespace */' >> "$release_file"
echo '#pragma GCC diagnostic pop' >> "$release_file"

# delete includes for non-standard header files from the release file
sed "/#include \"*\"/d" "$release_file" > "$release_file.tmp"
mv "$release_file.tmp" "$release_file"
