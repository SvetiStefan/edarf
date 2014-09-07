Functions useful for exploratory data analysis using random forests. Developed by [Zachary M. Jones](http://zmjones.com) in support of "[Data Mining as Exploratory Data Analysis](https://github.com/zmjones/datamining)."

This package allows you to easily calculate the partial dependence of an arbitrarily large set of explanatory variables on the response given a fitted random forest from [party](http://cran.r-project.org/web/packages/party/index.html), [randomForestSRC](http://cran.r-project.org/web/packages/randomForestSRC/index.html), and [randomForest](http://cran.r-project.org/web/packages/randomForest/index.html).

![](http://zmjones.com/static/images/bivariate_example.png)

It is not yet on CRAN, but you can install it from Github using [devtools](http://cran.r-project.org/web/packages/devtools/index.html). Pull requests, bug reports, feature requests, etc. are welcome.

### Classification

```{r}
require(randomForest)
require(party)
require(randomForestSRC)
require(parallel)
require(edarf)
data(iris)
CORES <- detectCores()

fit_rf <- randomForest(Species ~ ., iris)
fit_pt <- cforest(Species ~ ., iris, controls = cforest_control(mtry = 2))
fit_rfsrc <- rfsrc(Species ~ ., iris)

pd_rf <- partial_dependence(fit_rf, iris, "Petal.Width", CORES)
pd_pt <- partial_dependence(fit_pt, iris, "Petal.Width", CORES)
pd_rfsrc <- partial_dependence(fit_rfsrc, iris, "Petal.Width", CORES)

pd_int_rf <- partial_dependence(fit_rf, iris, c("Petal.Width", "Sepal.Length"), CORES)
pd_int_pt <- partial_dependence(fit_pt, iris, c("Petal.Width", "Sepal.Length"), CORES)
pd_int_rfsrc <- partial_dependence(fit_rfsrc, iris, c("Petal.Width", "Sepal.Length"), CORES)
```

### Regression

```{r}
data(swiss)

fit_rf <- randomForest(Fertility ~ ., swiss)
fit_pt <- cforest(Fertility ~ ., swiss, controls = cforest_control(mtry = 2))
fit_rfsrc <- rfsrc(Fertility ~ ., swiss)

pd_rf <- partial_dependence(fit_rf, swiss, "Education", CORES)
pd_pt <- partial_dependence(fit_pt, swiss, "Education", CORES)
pd_rfsrc <- partial_dependence(fit_rfsrc, swiss, "Education", CORES)

pd_int_rf <- partial_dependence(fit_rf, swiss, c("Education", "Catholic"), CORES)
pd_int_pt <- partial_dependence(fit_pt, swiss, c("Education", "Catholic"), CORES)
pd_int_rfsrc <- partial_dependence(fit_rfsrc, swiss, c("Education", "Catholic"), CORES)
```

### Survival

```{r}
data(veteran, package = "randomForestSRC")

fit_rfsrc <- rfsrc(Surv(time, status) ~ ., veteran)

pd_rfsrc <- partial_dependence(fit_rfsrc, veteran, "age", CORES)

pd_int_rfsrc <- partial_dependence(fit_rfsrc, veteran, c("age", "diagtime"), CORES)
```

Code to create the plot at the top is below.

```{r}
require(ggplot2)

p <- ggplot(pd_rf, aes(Education, pred))
p <- p + geom_point()
p <- p + stat_smooth()
p <- p + labs(x = "Years of Education", y = "Mean Prediction",
              title = "Partial Dependence of Fertility on Education")
```