import dotenv from "dotenv";
import express from "express";
dotenv.config(
    {path: './.env'}
)
import connectDB from './db/db_connection.js';
import app from './configs/express.config.js'

console.log("hello server");

connectDB()
.then(()=>{
    app.listen(process.env.PORT || 3000, ()=>{
        console.log("Server is running.........")
    })
})
.catch((error)=>{
    console.log("mongodb connection failed", error);
})