

# input int
N_days = input("Enter number of days: ")
N_days = int(N_days)
N_population = input("Enter number of population: ")
N_population = int(N_population)
first_sick = input("Enter number of first sick: ")
first_sick = int(first_sick)
infection_period = input("Enter number of infection period: ")
infection_period = int(infection_period)
infection_rate = input("Enter infection rate: ")
infection_rate = float(infection_rate)
mortality_rate = input("Enter mortality rate: ")
mortality_rate = float(mortality_rate)
meet_people = input("Enter number of people to meet: ")
meet_people = int(meet_people)

import random as r
# prepare the data
hs = [0] * N_population
dc = [0] * N_population

# 0 = healthy, 1 = sick, 2 = dead, 3 = immune

# day 0
hs[0 : first_sick] = [1]  * first_sick
dc[0 : first_sick] = [1]  * first_sick

# functions

def find_sick():
    cnt = 0
    for i in hs:
        if i == 1:
            cnt += 1
    return cnt

def meeting_people(cnt):
    for x in range(cnt):
        num_to_meet = r.randint(0, meet_people)
        for y in range(num_to_meet):
            idx = r.randint(0, N_population - 1)
            if hs[idx] == 0:
                if r.random() < infection_rate:
                    hs[idx] = 1
                    dc[idx] = 1

def prob_to_die_or_live():
    temp = []
    for i in range(N_population):
        if i == 1:
            temp.append(i)
            dc[i] += 1
    # prob to die
    for i in temp:
        if r.random() < mortality_rate:
            # dead
            hs[i] = 2
        else:
            if dc[i] >= 10:
                hs[i] = 3
                dc[i] = 0

def status():
    sick = hs.count(1)
    healthy = hs.count(0) + hs.count(3)
    dead = hs.count(2)
    print("Day %d: sick: %d, healthy: %d, dead: %d" % (day, sick, healthy, dead))

# all days
for day in range(1, N_days +1):
    prob_to_die_or_live()
    cnt = find_sick()
    if cnt == 0:
        break
    meeting_people(cnt)
    status()


