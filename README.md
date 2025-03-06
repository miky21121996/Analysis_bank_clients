# Analysis of clients of a bank

## Database Structure
The database consists of the following tables:

- Cliente: contains personal information about the customers (e.g., age).
- Conto: contains information about the accounts owned by customers.
- Tipo_conto: describes the different types of accounts available.
- Tipo_transazione: contains the types of transactions that can occur on accounts.
- Transazioni: contains details of the transactions made by customers on various accounts.
- Behavioral Indicators to Calculate
- The indicators will be calculated for each individual customer (referred to by id_cliente) and include:

## Basic Indicators
- Customer's age (from the cliente table).
- Transaction Indicators
- Number of outgoing transactions across all accounts.
- Number of incoming transactions across all accounts.
- Total amount of outgoing transactions across all accounts.
- Total amount of incoming transactions across all accounts.
- Account Indicators
- Total number of accounts owned.
- Number of accounts owned by type (one indicator for each account type).
- Transaction Indicators by Account Type
- Number of outgoing transactions by account type (one indicator for each account type).
- Number of incoming transactions by account type (one indicator for each account type).
- Total outgoing transaction amount by account type (one indicator for each account type).
- Total incoming transaction amount by account type (one indicator for each account type).
