-- Create the database if it doesn't exist
IF DB_ID('sipay') IS NULL
BEGIN
    CREATE DATABASE sipay;
END
GO