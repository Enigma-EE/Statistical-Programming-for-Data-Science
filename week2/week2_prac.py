# %% [markdown]
# ### prac week02
# ### Exercise 1: Loops

# %% [markdown]
# 1. Use a for loop to print the numbers 1 to 10 to the screen. Now write this using a while loop.

# %%
# Use a for loop to print the numbers 1 to 10
for i in range(1,11):
    print(i, end=' ')

# %%
# Use a while loop to print the numbers 1 to 10
i = 1
while i <= 10:
    print(i, end=' ')
    i += 1

# %% [markdown]
# 2. Use a while loop to print the temperature along with the statement “The Weather is Fine!” for as long as the temperature is between 20 and 30 degrees. To simulate the weather, you can use the randint() function from the random module, with the lower bound set to 16 and the upper bound to 40
# 

# %%
import random
# use a while loop to print the temperature
i = random.randint(16, 40)
print('The value of i is : ', i)
while i >= 20 and i <= 30: # 20 <= i <= 30
    print('The Weather is Fine!')
    break # to stop the loop
else:
    print('The Weather is not Fine!')

# %%
# use a for loop to print the temperature
i = random.randint(16, 40)
print('The value of i is : ', i)

for i in range(i, 41):
    if 20 <= i <= 30: # 20 <= i <= 30
        print('The Weather is Fine!')
        break # to stop the loop
else:
    print('The Weather is not Fine!')


# %%
# use a if statement to print the temperature
i = random.randint(16, 40)
print('The value of i is : ', i)
if i >= 20 and i <= 30: # 20 <= i <= 30
    print('The Weather is Fine!')
else:
    print('The Weather is not Fine!')
    

# %% [markdown]
# 3. Why can’t you implement this as a for loop?
# 

# %% [markdown]
# 4. Use a for/while loop to print the days of the week

# %%
# get weekdays using calendar module
import calendar
days = calendar.weekheader(3).split()
for day in days:
    print(day, end=' ')
    

# %%
# use a while loop print the days of the week
days_of_week = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

index = 0
while index < len(days_of_week):
    print(days_of_week[index], end=' ')
    index += 1

# %% [markdown]
# ### Exercise 2: Loops and Input Processing

# %% [markdown]
# 1. Prompts the user to enter five comma-separated integer numbers.
# 2. Prints an error message if the user enters less than 5 numbers.
# 3. Outputs the sum of these numbers to the screen.
# 4. Outputs the number of valid values used in producing the cumulative sum.

# %%
number_int = input('Enter five comma-separated integer numbers: ')
number_list = number_int.split(',')
# if the user enters not numbers,treat as NaN and exclude from the sum
number_list = [int(i) for i in number_list if i.isdigit()]
print('The numbers are: ', number_list)
# print('The original list is: ', number_list)

# Prints an error message if the user enters less than 5 numbers
if len(number_list) != 5:
    print('You have not entered five numbers, the sum is', sum(number_list))
else:
    print('The sum of the numbers is: ', sum(number_list))
    # output the sum of the numbers

# Outputs the number of valid values used in producing the cumulative sum
print('The number of valid values used in producing the cumulative sum is: ', len(number_list))

# %%
nums = input('Enter five comma-separated numbers: ')
nums = nums.split(',')

if len(nums) != 5:
    print('You have not entered five numbers, the sum is', sum([int(i) for i in nums if i.isdigit()]))

# sum the numbers
good_nums = []
bad_nums = []

for i in nums:
    try:
        good_nums.append(float(i))
    except:
        bad_nums.append(i)

print('The valid numbers are: ', good_nums)
print('The sum of the numbers is: ', sum(good_nums))
print('The number of valid values used in producing the cumulative sum is: ', len(good_nums))
print('The invalid values are: ', bad_nums)

# %%
nums = input('Enter five comma-separated numbers: ')
nums = nums.split(',')

if len(nums) != 5:
    print('You have not entered five numbers')

# sum the numbers

for i in range(len(nums)):
    try:
        # foolproof
        nums[i] = float(nums[i]) # convert the string to a float
    except:
        nums[i] = 0 # replace the invalid value with 0

print('The sum of the numbers is: ', sum(nums))
print('The number of valid values used in producing the cumulative sum is: ', len(nums)-nums.count(0))
print('The invalid values are: ', nums.count(0))

# %%
# bad code
nums = input('Enter five comma-separated numbers: ')
nums = nums.split(',')

while len(nums) != 5:
    print('You have not entered five numbers')
    nums = input('Enter five comma-separated numbers: ')
    nums = nums.split(',') 

# %%
# loop until the user enters five numbers
for i in range(5):
    nums = input('Enter five comma-separated numbers: ')
    nums = nums.split(',')
    if len(nums) == 5:
        break
    else:
        print('You have not entered five numbers')
else :
    print('You have not entered five numbers')

# sum the numbers
if len(nums) == 5:
    for i in range(len(nums)):
        try:
            # foolproof
            nums[i] = float(nums[i]) # convert the string to a float
        except:
            nums[i] = 0 # replace the invalid value with 0

    print('The sum of the numbers is: ', sum(nums))
    print('The number of valid values used in producing the cumulative sum is: ', len(nums)-nums.count(0))
    print('The invalid values are: ', nums.count(0))

# %%
while True:
    nums = input('Enter five comma-separated numbers: ')
    nums = nums.split(',')
    if len(nums) == 5:
        break
    else:
        print('You have not entered five numbers')

# sum the numbers
for i in range(len(nums)):
    try:
        # foolproof
        nums[i] = float(nums[i]) # convert the string to a float
    except:
        nums[i] = 0 # replace the invalid value with 0

print('The sum of the numbers is: ', sum(nums))
print('The number of valid values used in producing the cumulative sum is: ', len(nums)-nums.count(0))
print('The invalid values are: ', nums.count(0))

# %% [markdown]
# ### Exercise 3: The mean of a data set

# %% [markdown]
# Write a script that computes the mean of a user-supplied tuple that contains at least 5 numbers. 
# 1. Prompts the user to enter at least five comma-separated integer numbers.
# 2. Check the entry contains numbers. If there are any non-numerical elements treat these element as a NaN.
# 3. Determine the number of valid numbers.
# 4. Compute the mean. If there are NaNs, the calculation of the mean should be adjusted, to take only
# genuine numbers into account.
# 5. Display the original entry, the mean and the number of valid numbers to the screen

# %%
number_int = input('Enter at least five comma-separated integer numbers: ')
number_list_0 = number_int.split(',')
# if the user enters not numbers,treat as NaN and exclude from the sum
number_list = [int(i) for i in number_list_0 if i.isdigit()]
print('The numbers are: ', number_list)

print('The number of valid values is: ', len(number_list))
# compute the mean
num_mean = sum(number_list) / len(number_list)
print('The mean of the numbers is: ', float(num_mean))
print('The original list is: ', number_list_0)

# %% [markdown]
# ### Exercise 4: The standard deviation of a data set

# %% [markdown]
# Expand the script from Exercise 3 to also compute the standard deviation of the numerical elements. If
# there are less than 3 numerical elements entered, do not calculate the standard deviation. The full output
# should now be:
# 1. The original entry
# 2. The mean
# 3. The standard deviation, if calculated, otherwise display a message telling the user the standard deviation was not able to be calculated.
# 4. The number of valid numbers.

# %%
number_int = input('Enter at least five comma-separated integer numbers: ')
number_list_0 = number_int.split(',')
print('The original list is: ', number_list_0)
# if the user enters not numbers,treat as NaN and exclude from the sum
number_list = [int(i) for i in number_list_0 if i.isdigit()]
print('The numbers are: ', number_list)
print('The number of valid values is: ', len(number_list))

#  If there are less than 3 numerical elements entered, do not calculate the standard deviation
if len(number_list) < 3:
    print('There are less than 3 numerical elements entered, do not calculate the standard deviation')
else:
    # compute the mean
    num_mean = sum(number_list) / len(number_list)
    # compute the standard deviation
    num_std = (sum([(i - num_mean) ** 2 for i in number_list]) / len(number_list)) ** 0.5
    print('The standard deviation of the numbers is: ', num_std)



# %%
number_d = input('Enter at least five comma-separated numbers: ')
number_list_0 = number_d.split(',')
print('The original list is: ', number_list_0)
# if the user enters not numbers,treat as NaN and exclude from the sum
number_list = [float(i) for i in number_list_0 if i.replace('.', '', 1).isdigit()] # replace('.', '', 1) replace the first dot
print('The numbers are: ', number_list)
 
if len(number_list) >= 5:
    print('The number of valid values is: ', len(number_list))
else:
    print('The number of valid values is less than 5.')

import statistics # import the statistics module
#  If there are less than 3 numerical elements entered, do not calculate the standard deviation
def mean_std_deviation():
    # compute the mean
    num_mean = statistics.mean(number_list)
    # mean desplay 2 decimal places
    print('The mean of the numbers is: ', format(num_mean, '.2f'))
    # compute the standard deviation
    num_std = statistics.stdev(number_list)
    print('The standard deviation of the numbers is: ', format(num_std, '.2f'))
mean_std_deviation()


# %% [markdown]
# ### Exercise 5: Strings
# 

# %% [markdown]
# For this exercise, you are asked to write a program that takes a string input from the user, and returns, as
# output, the entire message minus the vowels (a,e,i,o,u). E.g. if the input message is\
# **Tim thinks this is a good exercise to try.**\
# The output should look as follows:\
# **Tm thnks ths s gd xrcs t try**
# 

# %%
import re
string_example = input("Enter a string: ")
# I added Quiz 2 based on this week material and two examples of Test 1 from previous years
string_without_vowels = re.sub("[aeiouAEIOU]","",string_example)
print(string_without_vowels)

# %%
def remove_vowels(string):
  new_string = ""
  for char in string:
    if char.lower() not in "aeiou":
      new_string += char
  return new_string

string_example = input("Enter a string: ")
# I added Quiz 2 based on this week material and two examples of Test 1 from previous years
string_without_vowels = remove_vowels(string_example)
print(string_without_vowels)

# %% [markdown]
# ### Exercise 6: String-palindrome

# %% [markdown]
# Write a program that takes, as input, any word or phrase, entered by the user, and determine whether that word or phrase is a palindrome. A palindrome is a word that reads the same in reverse order, 
# e.g.\
# • glenelg\
# • Anna

# %%
# whether the string is a palindrome
string_1 = input('Enter a string: ')
# convert the string to lowercase and remove the spaces
string_2 = string_1.lower().replace(' ', '')
# reverse the string and compare it with the original string
if string_2 == string_2[::-1]:# slice the string from the end to the beginning
    print('The string is a palindrome')
else:
    print('The string is not a palindrome')

# %%
text = 'Amore roma'

text = text.lower()
text_clean =""

for cnt in text:
    if cnt.isalpha():
        text_clean = text_clean + cnt

my_text = text_clean[::-1]
text_clean == my_text

# %%
text = 'Amore roma'

text = text.lower()
text_clean =""

for cnt in text:
    if cnt.isalpha():
        text_clean = text_clean + cnt

my_text = list(text_clean)
my_text.reverse()
my_text = "".join(my_text)

if text_clean == my_text:
    print("The string is a palindrome")
else:
    print("The string is not a palindrome")

# %% [markdown]
# ### Exercise 7: Game 21

# %% [markdown]
# For this simplified version of the game, the cards drawn can take values 2 through to 11. Your code should:
# 1. Prompt the player to draw one card and display the value of the card drawn.
# 2. Ask whether they want to draw another card, or finish their game.
# 3. If the player chooses to finish the game, output the sum of the cards drawn and the value of the next card, should they have chosen to draw another card. If the sum plus the value of the next card exceeds 21, print a congratulations message for stopping in time. Otherwise, print a loser’s message.
# 4. If the user chooses to draw another card, then if the sum of the cards drawn to date plus the newly drawn card exceeds 21, output the sum and a loser’s message. Otherwise go to step 2 above.
# 5. If you would like an extra challenge, then treat the value of 11 as the Ace card. This means that thecard can then either take on the value of 11, or the value of 1. If the user draws 11 and the value of 11 will cause them to lose, change the value to 1. Otherwise, keep the value of the card drawn as 11.

# %%
# 1

import random

# initialize variables
cards = []
sum_cards = 0

# while loop to keep drawing cards until the sum exceeds 21 or user stops
while sum_cards < 21:
    card = random.randint(2, 11) 
    cards.append(card)  # add new card to list of cards drawn
    print('The value of the card is:', card)
    
    # calculate total sum of cards
    sum_cards = sum(cards)
    
    # check if user wants to draw another card
    draw_again = input('Do you want to draw another card? (y/n): ')
    
    # exit loop if user doesn't want to draw another card
    if draw_again.lower() == 'n':
        print('the sum of the cards is: ', sum_cards)
        break
        
# check if user won or lost
if sum_cards > 21:
    print('You lost')
else:
    print('You have reached a total of', str(sum_cards) + '.')

# %%
# 2 - without break statement and using a boolean variable
#   - change the value of 11 to 1 if the sum exceeds 21
import random

playing = True # boolean variable to control the while loop
sum_card = 0 # variable to store the sum of the cards drawn

while playing: # while loop to keep drawing cards until the sum exceeds 21 or user stops
    card = random.randint(2, 11) # draw a random card
    # if card == 11 and sum > 21, change the value of the card to 1
    if card == 11 and sum_card + card > 21:
        card = 1
    print(f"The value of the card is: {card}") # print the value of the card
    
    sum_card += card # add the value of the card to the sum of the cards
    
    if sum_card > 21:
        print("You Lost!")
        playing = False # exit the while loop
    else:
        draw_again = input("Do you want to draw another card? (y/n)") # ask the user if he wants to draw another card
        
        if draw_again.lower() == 'n':
            print(f"The total sum of cards drawn is: {sum_card}")
            playing = False # exit the while loop



