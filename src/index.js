import dotenv from "dotenv";
import express from "express";
dotenv.config(
    {path: './.env'}
)
import connectDB from './db/db_connection.js';
import app from './configs/express.config.js'

connectDB()
.then(()=>{
    const port = process.env.PORT || 3000;
    app.listen(port, ()=>{
        console.log(`Server is running on port ${port}`)
    })
})
.catch((error)=>{
    console.log("mongodb connection failed", error);
})