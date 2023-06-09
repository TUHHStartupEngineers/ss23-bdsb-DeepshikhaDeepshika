# Data Science at TUHH ------------------------------------------------------
# SALES ANALYSIS ----

# 1.0 Load libraries ----
library("tidyverse")
library("readxl")

# 2.0 Importing Files ----
bikes_tbl      <- read_excel("ds_data/01_bike_sales/01_raw_data/bikes.xlsx")
orderlines_tbl <- read_excel("ds_data/01_bike_sales/01_raw_data/orderlines.xlsx")
bikeshops_tbl  <- read_excel("ds_data/01_bike_sales/01_raw_data/bikeshops.xlsx")

# 3.0 Examining Data ----
orderlines_tbl
bikes_tbl
glimpse(orderlines_tbl)
# 4.0 Joining Data ----
bike_orderlines_joined_tbl <- orderlines_tbl %>%
  left_join(bikes_tbl, by = c("product.id" = "bike.id")) %>%
  left_join(bikeshops_tbl, by = c("customer.id" = "bikeshop.id"))
bike_orderlines_joined_tbl %>% glimpse()
bike_orderlines_joined_tbl
# 5.0 Wrangling Data ----
bike_orderlines_joined_tbl$category
bike_orderlines_joined_tbl %>% 
  select(category) %>%
  filter(str_detect(category, "^Mountain")) %>% 
  unique()

# All actions are chained with the pipe already. You can perform each step separately and use glimpse() or View() to validate your code. Store the result in a variable at the end of the steps.
bike_orderlines_joined_tbl
bike_orderlines_wrangled_tbl <- bike_orderlines_joined_tbl
bike_orderlines_wrangled_tbl <- bike_orderlines_wrangled_tbl %>%
  separate(col    = category,
           into   = c("category.1", "category.2", "category.3"),
           sep    = " - ") %>%
  
  mutate(total.price = price * quantity) %>%
  select(-...1, -gender) %>%
  select(-ends_with(".id")) %>%
  bind_cols(bike_orderlines_joined_tbl %>% select(order.id)) %>% 
  select(order.id, contains("order"), contains("model"), contains("category"),
         price, quantity, total.price,
         everything()) %>%
  rename(bikeshop = name) %>%
  set_names(names(.) %>% str_replace_all("\\.", "_"))
# 6.0 Business Insights ----
# 6.1 Sales by Year ----

# Step 1 - Manipulate
library("lubridate")

sales_by_year_tbl <- bike_orderlines_wrangled_tbl
sales_by_year_tbl <- sales_by_year_tbl %>%
 select(order_id, order_date, quantity, price, total_price) %>%
 mutate(order_year = year(order_date)) %>%
 group_by(order_year) %>%
 summarize(sales = sum(total_price))


# Step 2 - Visualize


# 6.2 Sales by Year and Category 2 ----
sales_by_year_tbl %>%
  
  # Setup canvas with the columns year (x-axis) and sales (y-axis)
  ggplot(aes(x = order_year, y = sales)) +
  
  # Geometries
  geom_col(fill = "#2DC6D6") + # Use geom_col for a bar plot
  geom_label(aes(label = sales)) + # Adding labels to the bars
  geom_smooth(method = "lm", se = FALSE) + # Adding a trendline
  
  # Formatting
  # scale_y_continuous(labels = scales::dollar) + # Change the y-axis. 
  # Again, we have to adjust it for euro values
  scale_y_continuous(labels = scales::dollar_format(big.mark = ".", 
                                                    decimal.mark = ",", 
                                                    prefix = "", 
                                                    suffix = " €")) +
  labs(
    title    = "Revenue by year",
    subtitle = "Upward Trend",
    x = "", # Override defaults for x and y
    y = "Revenue"
  )
# Step 1 - Manipulate
library("lubridate")

sales_by_year_category_tbl <- bike_orderlines_wrangled_tbl
sales_by_year_category_tbl <- sales_by_year_category_tbl %>%
  select(order_id, order_date, quantity, price, category_1, total_price) %>%
  mutate(order_year = year(order_date)) %>%
  group_by(order_year, category_1) %>%
  summarise(sales = sum(total_price)) %>%
  ungroup() %>%
  mutate(sales_text = scales::dollar(sales, big.mark = ".", 
                                     decimal.mark = ",", 
                                     prefix = "", 
                                     suffix = " €"))

sales_by_year_category_tbl
  

# Step 2 - Visualize
sales_by_year_category_tbl %>%
  
  # Setup canvas with the columns year (x-axis) and sales (y-axis)
  ggplot(aes(x = order_year, y = sales, fill = category_1)) +
  
  # Geometries
  geom_col() +
  #geom_col(fill = "#2DC6D6") + # Use geom_col for a bar plot
  #geom_label(aes(label = sales_text)) + # Adding labels to the bars
  geom_smooth(method = "lm", se = FALSE) + # Adding a trendline
  
  #facets
  facet_wrap(~category_1)+
  # Formatting
  # scale_y_continuous(labels = scales::dollar) + # Change the y-axis. 
  # Again, we have to adjust it for euro values
  scale_y_continuous(labels = scales::dollar_format(big.mark = ".", 
                                                    decimal.mark = ",", 
                                                    prefix = "", 
                                                    suffix = " €")) +
  labs(
    title    = "Revenue by year and main category",
    subtitle = "Each product category has an upward trend",
    fill = "Main category"
    #x = "", # Override defaults for x and y
    #y = "Revenue"
  )


# 7.0 Writing Files ----

# 7.1 Excel ----
install.packages("writexl")
library("writexl")
bike_orderlines_wrangled_tbl %>%
  write_xlsx("ds_data/01_bike_sales/02_wrangled_data/bike_orderlines.xlsx")

# 7.2 CSV ----
bike_orderlines_wrangled_tbl %>% 
  write_csv("ds_data/01_bike_sales/02_wrangled_data/bike_orderlines.csv")

# 7.3 RDS ----
bike_orderlines_wrangled_tbl %>% 
  write_rds("ds_data/01_bike_sales/02_wrangled_data/bike_orderlines.rds")

