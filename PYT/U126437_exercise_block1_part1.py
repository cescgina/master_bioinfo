def get_sphere_volume(radius):
    """Return the volume of a sphere of a specified radius"""
    import math
    return (4/3)*math.pi*radius**3

def recursive_factorial(n):
    """Return the factorial of n, calculated recursevely"""
    if not str(n).isdigit() or n<0:
        return "Call recursive_factorial with an integer"
    if n < 2:
        return 1
    else:
        return n * recursive_factorial(n-1)

def factorial(n):
    """Return the factorial of n, calculated iteratively"""
    if not str(n).isdigit() or n < 0:
        return "Call factorial with an integer"
    result=1
    for x in range(1,n+1):
        result *= x
    return result

def count_up(n, odd=False):
    """Prints on the screen the numbers from 0 to n, if odd=true, only odd numbers are displayed"""
    if not str(n).isdigit() or n<0:
        print("Call count_up with an integer")
        return 
    if odd:
        counter=[ x for x in range(n+1) if x % 2 != 0]
    else:
        counter=[x for x in range(n+1)]
    print("Start counting from 0 to %d" % n)
    for num in counter:
        print(num)
    return 

def get_final_price(price,discount_percentage=10):
    """Return the final price after applying the discount percentatge"""
    return price - price * discount_percentage / 100

#if __name__ == '__main__':
#    print(get_sphere_volume(1))
#    print("")
#    print(recursive_factorial(6))
#    print("")
#    print(factorial(3))
#    print("")
#    count_up(6)
#    print("")
#    count_up(4,odd=True)
#    print("")
#    print(get_final_price(100))
