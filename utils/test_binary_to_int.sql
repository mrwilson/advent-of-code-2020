.load binary_to_int.dylib

select
    binary_to_int("01010"),
    binary_to_int("11010"),
    binary_to_int("0"),
    binary_to_int("111111111");
