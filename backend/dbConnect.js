import dotenv from 'dotenv'
dotenv.config();
import mongoose from "mongoose";

const mainConnect = async () => {
    try {
         await mongoose.connect(process.env.MONGODB_URL)
         console.log('Succesfully connected to Mongodb Atlas Server')
    }
    catch(err) {
       console.log(err.message);
    }
}

export default mainConnect;