import pandas as pd
import sqlite3

# Load cleaned dataset
df = pd.read_csv("dataset/clean_sales_data.csv")

# Connect to SQLite database
connection = sqlite3.connect("dataset/ecommerce.db")

# Create sales table
df.to_sql("sales", connection, if_exists="replace", index=False)

# Close connection
connection.close()

print("SQLite database created successfully!")