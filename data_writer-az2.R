# translated perl to R code:

# open an output file to attach the results of this code to that file
outfile <- character()

alphabet <- c(letters)
betabet <- c(LETTERS)

winik <- data.frame(pop_size = NA,
                    father_name = NA,
                    mother_name = NA,
                    age = NA,
                    is_alive = NA,
                    fatherinlaw_name = NA,
                    is_pregnant = NA,
                    issue_quant = NA)

start <- 16280
birth <- integer()
kids <- integer()
for (i in 1:13) {           # will start from 1 because array indexes start at 1 in R
  birth <- floor(100 + runif(1,0,100))
  kids <- 3 + floor(runif(1,0,3))

  # creating a temporary data frame that will create new rows with new data values
  # to replace the instantiations of the winik data frame
  tmp <- data.frame(id = i,
                    father_name = alphabet[i],
                    mother_name = alphabet[i + 13],
                    gender = 'M',
                    offspring = birth,
                    population = start - birth,
                    is_alive = 1,
                    is_married = 1,
                    id_partners_father = i+13,
                    is_pregnant = 0,
                    kids_count = kids)

  # first time it runs winik will be just known as this tmp data frame
  # and the new creation of data will be added on as a row to this data frame
  # through rbind()
  if(i==1)
    winik <- tmp
  else
    winik <- rbind(winik, tmp)

  rm(birth, kids, tmp) # will delete the dummy variables created
}

# the creation of tmp data frames will be created 3 more times to not
# effect the previously created data. This includes a tmp winik data frame
# that will be combined from the previous data and the new generated
# data in the following loop, again through rbind()
winik2 <- winik

for (i in 1:13) {           # will start from 1 because array indexes start at 1 in R
  birth <- winik[i,5] + floor(5*runif(1,0,100))
  kids <- 3 + floor(runif(1,0,3))
  tmp2 <- data.frame(id = i+13,
                     father_name = alphabet[i+13],
                     mother_name = alphabet[i],
                     gender = 'F',
                     offspring = birth,
                     population = start - birth,
                     is_alive = 1,
                     is_married = 1,
                     id_partners_father = i,
                     is_pregnant = 0,
                     kids_count = kids)
  if(i==1)
    winik2 <- tmp2
  else
    winik2 <- rbind(winik2, tmp2)
  rm(birth, kids, tmp2)
}

winik <- rbind(winik,winik2)
# this will combine the two winik data frames and we will continue this for
# winik3 and winik4

winik3 <- winik
for (i in 1:13) {
  birth <- floor(100 + runif(1,0,100))
  kids <- 3 + floor(runif(1,0,3))
  tmp3 <- data.frame(id = i+26,
                     father_name = betabet[i],
                     mother_name = betabet[i+13],
                     gender = 'M',
                     offspring = birth,
                     population = start - birth,
                     is_alive = 1,
                     is_married = 1,
                     id_partners_father = i+39,
                     is_pregnant = 0,
                     kids_count = kids)
  if(i==1)
    winik3 <- tmp3
  else
    winik3 <- rbind(winik3, tmp3)
  rm(birth, kids, tmp3)
}

winik <- rbind(winik,winik3)

winik4 <- winik

for (i in 1:13) {
  birth <- winik[i,5] + floor(5*runif(1,0,100))
  kids <- 3 + floor(runif(1,0,3))
  tmp4 <- data.frame(id = i+39,
                     father_name = betabet[i+13],
                     mother_name = betabet[i],
                     gender = 'F',
                     offspring = birth,
                     population = start - birth,
                     is_alive = 1,
                     is_married = 1,
                     id_partners_father = i+26,
                     is_pregnant = 0,
                     kids_count = kids)
  if(i==1)
    winik4 <- tmp4
  else
    winik4 <- rbind(winik4, tmp4)
  rm(birth, kids, tmp4)
}

winik <- rbind(winik,winik4)

rm(winik2,winik3,winik4)

j <- 53
rnum <- runif(1,0,100)

# will create data for rows from 53 to ~150-160
# filling in data for the offspring of parents from rows 14:26 and 40:52
for (i in c(14:26,40:52)) {
  birth <-  winik[i,5] + 5844 + floor(365.25*runif(1,0,5))
  index <- winik[i,11]
  for (m in 1:index) {
    # for that array index in the last column, winik[i,11], this for loop
    # will run from 1 to that amount of children and fill in data for that child
    winik[j,1] <- j
    winik[j,2] <- winik[i,2]
    winik[j,3] <- winik[i - 13,2]
    rnum <- runif(1,0,100)
    if (rnum < 53) {
      winik[j,4] <- 'F'
    } else {
      winik[j,4] <- 'M'
    }
    # assigning the child's parameters
    winik[j,5] <- birth                   # offspring column
    winik[j,6] <- start - birth           # population column
    winik[j,7] <- 1                       # is_alive column
    winik[j,8] <- 0                       # is_married column
    winik[j,9] <- 'NULL'                  # id_partners_father column
    winik[j,10] <- 0                      # is_pregnant column
    winik[j,11] <- 0                      # kids_count column
    birth <- birth + 400 + floor(365.25*runif(1,0,2))
    j <- j + 1
  }
}

# The following will allow for marriage between M & F of 16 < age < 40
# marriage between the children created before
# does not consider time as a parameter
for (i in 27:j-1) {
  if ((winik[i,8] == 0) && (winik[i,6] > 5844) &&
      (winik[i,6] < 14610) && (winik[i,4] == 'F')) {
    k <- 27
    while((k <= j-1) && (winik[i,8] != 1)) {
      if((winik[k,4]) == 'M' && (winik[k,6] > 5844) &&
         (abs(winik[k,6] - winik[i,6]) < 1460) && (winik[k,8]==0) &&
         (winik[k,2]) != winik[i,1]) { # perl: !~
        winik[i,8] <- 1;              # is_married column
        winik[k,8] <- 1;              # is_married column
        winik[i,9] <- winik[k,1]      # id_part_father column <- id column
        winik[k,9] <- winik[i,1]      # id_part_father column <- id column
      }
      k <- k + 1
    }
  }
}

h <- integer()

print("j before the function running is ")
print(j)
# The following allow for births for married females under 40 (time not yet implemented)
# and with < 6 children
inc <- j-1
for (aa in 27:inc) {
  if ((winik[aa,4] == 'F') && (winik[aa,6] < 14610) && (winik[aa,8] == 1)) {
    h <- 0
    birth <- winik[aa,5] + 5844 + floor(365.25*runif(1,0,3))
    while ((winik[aa,11] < 6) && ((start - birth) > 0)) {
      winik[inc,1] <- inc                        # id column
      winik[inc,2] <- winik[aa,2]                # father_name column
      winik[inc,3] <- winik[(winik[aa,9]),2]     # mother_name column <- father_name column
      rnum <- runif(1,0,100)
      if (rnum < 53) {
        winik[inc,4] = 'F'
      } else {
        winik[inc,4] = 'M'
      }
      winik[inc,5] <- birth                     # offspring column
      winik[inc,6] <- start - birth             # population column
      winik[inc,7] <- 1                         # is_alive column
      winik[inc,8] <- 0                         # is_married column
      winik[inc,9] <- 'NULL'                    # id_partners_father column
      winik[inc,10] <- 0                        # is_pregnant column
      winik[inc,11] <- 0                        # kids_count column
      birth <- birth + 400 + floor(365.25*runif(1,0,2))
      inc <- inc + 1
      h <- h + 1
      winik[aa,11] <- h
      winik[(winik[aa,9]),11] <- h
    }
  }
}
size <- dim(winik)
print("The size of the winik data frame is (rows col): ")
size

# will save a file data-wrte-az.csv in the user's local directory and will have
# the output data from the winik data frame
path <- file.path("~", "data-writer-az.csv")    # will use the user's local directory
outfile <- write.csv(winik,path)
if (is.null(path)) {
  print("ERROR: data-write-az.csv file not saved successfully")
  # if local directory isn't setup, the file will not save
} else {
   print("data-writer-az.csv successfully saved in user's local directory")
}

View(winik,"Data From Winik Data Frame")

print("Done\n")


