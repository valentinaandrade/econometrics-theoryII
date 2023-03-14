# setup -------------------------------------------------------------------
library(tidyverse)
library(broom)
library(haven)

# data --------------------------------------------------------------------
data <- haven::read_dta("01input/src/data_pregunta1.dta")

data <- data |> 
  select(
    y = municipal, 
    x1 = cod_nivel,
    x2 = es_mujer,
    x3 = prioritario,
    x4 = alto_rendimiento
    ) 

modelo <- glm(y ~ x1 + x2 + x3 + x4, family = binomial(), data = data)

summary(modelo)

broom::tidy(modelo)

broom::glance(modelo)


# newton rapshon ----------------------------------------------------------
# Define the response variable and explanatory variables
y <- as.numeric(data$y)
x <- as.matrix(data[, -y])

# Add a column of ones to the design matrix for the intercept term
x <- cbind(1, x)

# Define the log-likelihood function for logistic regression
log_likelihood <- function(beta, x, y) {
  mu <- plogis(x %*% beta) # Compute the predicted probabilities
  log_likelihood <- sum(y * log(mu) + (1 - y) * log(1 - mu)) # Compute the log-likelihood
  return(-log_likelihood) # Return the negative log-likelihood (for minimization)
}

log_likelihood(modelo$coefficients, x, y)
broom::glance(modelo)$logLik

# Define the derivative of the log-likelihood function
log_likelihood_derivative <- function(beta, x, y) {
  mu <- plogis(x %*% beta) # Compute the predicted probabilities
  residuals <- y - mu # Compute the residuals
  derivative <- t(x) %*% residuals # Compute the derivative
  # se cambia signo!
  return(derivative) # Return the negative derivative (for minimization)
}

# Define the second derivative of the log-likelihood function (Hessian matrix)
log_likelihood_second_derivative <- function(beta, x, y) {
  mu <- plogis(x %*% beta) # Compute the predicted probabilities
  w <- mu * (1 - mu) # Compute the weights
  # acá se tranforma a vector por si acaso
  hessian <- t(x) %*% diag(as.vector(w)) %*% x # Compute the Hessian matrix
  return(-hessian) # Return the negative Hessian matrix (for minimization)
}

# Set the starting values for the parameters
beta <- rep(0, ncol(x))

# Set the convergence tolerance and maximum number of iterations
tol <- 1e-6
max_iter <- 1000

# Iterate until convergence or maximum number of iterations is reached
for (i in 1:max_iter) {
  
  message(i)
  
  # Compute the gradient and Hessian matrix
  gradient <- log_likelihood_derivative(beta, x, y)
  hessian <- log_likelihood_second_derivative(beta, x, y)
  
  # Check for convergence
  if (max(abs(gradient)) < tol) {
    break
  }
  
  # Update the parameter estimates using the Newton-Raphson method
  beta <- beta - as.vector(solve(hessian) %*% gradient)
  
}

# betas
beta
broom::tidy(modelo)$estimate

# std error
sqrt(diag(solve(-hessian)))
broom::tidy(modelo)$std.error



# robusto? ----------------------------------------------------------------
robustse <- function(x, coef = c("logit", "odd.ratio", "probs")) {
  suppressMessages(suppressWarnings(library(lmtest)))
  suppressMessages(suppressWarnings(library(sandwich)))
  
  sandwich1 <- function(object, ...) sandwich(object) *
    nobs(object) / (nobs(object) - 1)
  # Function calculates SE's
  mod1 <- coeftest(x, vcov = sandwich1) 
  # apply the function over the variance-covariance matrix
  
  if (coef == "logit") {
    return(mod1) # return logit with robust SE's
  } else if (coef == "odd.ratio") {
    mod1[, 1] <- exp(mod1[, 1]) # return odd ratios with robust SE's
    mod1[, 2] <- mod1[, 1] * mod1[, 2]
    return(mod1)
  } else {
    mod1[, 1] <- (mod1[, 1]/4) # return probabilites with robust SE's
    mod1[, 2] <- mod1[, 2]/4
    return(mod1)
  }
}

modelo
modelor <- robustse(modelo, coef = "logit")
modelor

broom::tidy(modelo)$std.error
modelor[, 2]


