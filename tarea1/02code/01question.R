# Question 1- Logit models ------------------------------------------------

# 1. Load packages --------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, haven)

# 2. Load data ------------------------------------------------------------
data <- haven::read_dta("01input/src/data_pregunta1.dta")

# a. Likelihood function --------------------------------------------------
manual_logistic_regression = function(X,y,threshold = 1e-10, max_iter = 100)
  #A function to find logistic regression coeffiecients 
  #Takes three inputs: 
{
  #A function to return p, given X and beta
  #We'll need this function in the iterative section
  calc_p = function(X,beta)
  {
    beta = as.vector(beta)
    return(exp(X%*%beta) / (1+ exp(X%*%beta)))
  }  
  
  #### setup bit ####
  
  #initial guess for beta
  beta = rep(0,ncol(X))
  
  #initial value bigger than threshold so that we can enter our while loop 
  diff = 10000 
  
  #counter to ensure we're not stuck in an infinite loop
  iter_count = 0
  
  #### iterative bit ####
  while(diff > threshold ) #tests for convergence
  {
    #calculate probabilities using current estimate of beta
    p = as.vector(calc_p(X,beta))
    
    #calculate matrix of weights W
    W =  diag(p*(1-p)) 
    
    #calculate the change in beta
    beta_change = solve(t(X)%*%W%*%X) %*% t(X)%*%(y - p)
    
    #update beta
    beta = beta + beta_change
    
    #calculate how much we changed beta by in this iteration 
    #if this is less than threshold, we'll break the while loop 
    diff = sum(beta_change^2)
    
    #see if we've hit the maximum number of iterations
    iter_count = iter_count + 1
    if(iter_count > max_iter) {
      stop("This isn't converging, mate.")
    }
  }
  #make it pretty 
  coef = c("(Intercept)" = beta[1], x1 = beta[2], x2 = beta[3], x3 = beta[4])
  return(coef)
}

set.seed(2016)
#simulate data 
#independent variables
x1 = data[,"cod_nivel"]
x2 = data[, "es_mujer"]
x3 = data[, "prioritario"]
x4 = data[, "alto_rendimiento"]


#dependent variable 
y = data[,"municipal"]
x0 = rep(1,222) #bias
X = cbind(x0,x1,x2,x3,x4)
manual_logistic_regression(X, y)
manual_logistic_regression(data %>% mutate(x0= rep(1,222)) %>%  select(x0, cod_nivel, es_mujer, prioritario, alto_rendimiento), data %>% select(municipal))

# b. Marginal effects -----------------------------------------------------


# c. Descriptives ---------------------------------------------------------


# d. Multinomial logit ----------------------------------------------------



# e. Conditional logit ----------------------------------------------------



# f. Mixed logit ----------------------------------------------------------

 

# g. Ordered logit --------------------------------------------------------


