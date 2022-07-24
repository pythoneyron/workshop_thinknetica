double_value_function = -> (x) { x * 2 }
complex_function = -> (x) { x > 0 ? x * 3 : x + 3 }

double_array_function = -> (arr) { arr.map(&double_value_function) }
complex_array_function = -> (arr) { arr.map(&complex_function) }

arr = [1,2,3,4,-5]

complex_array_function.call(double_array_function.call(arr))
