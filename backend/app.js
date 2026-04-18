import dotenv from 'dotenv'
dotenv.config();

import express from 'express';
import cors from "cors";
import bodyParser from 'body-parser';
import cookieParser from 'cookie-parser';
import mainConnect from './dbConnect.js';
import { userRouter } from './src/controllers/userController.js';

const app = express();
app.use(cors())
app.use(cookieParser())
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

await mainConnect();
app.use(userRouter);
const port = process.env.PORT;

app.listen(port, () => console.log(`Server listening on port ${port}`));