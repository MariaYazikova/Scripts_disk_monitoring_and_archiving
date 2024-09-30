import random

def student():
    n_par = 6
    water = 19
    ver = 5
    ver_step = 10
    water_step = 5
    for para in range (1, n_par + 1):
        water = water - water_step
        ver = ver + ver_step
        x = random.randint(1, 100)
        if x <= ver and water > 0:
            print("Студент захотел пить и попил на {} паре".format(para))
        elif x <= ver:
            print("Студент захотел пить на {} паре".format(para))
        else:
            print("Студент не хочет пить на {} паре".format(para))

student()