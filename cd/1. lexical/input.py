def calculate_average(numbers):
    """This function calculates the average"""
    total = sum(numbers)
    count = len(numbers)
    
    if count == 0:
        return 0  # Avoid division by zero
    else:
        return total / count

data = [10, 20, 30, 40, 50]
average = calculate_average(data)

print(f"The average is: {average:.2f}")
