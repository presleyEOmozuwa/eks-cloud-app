import express from "express";
import { insertUsers, createUser } from "../services/userService.js";

export const userRouter = express.Router();

userRouter.get("/api/users", async (req, res) => {
   const users = await insertUsers();
   res.json({ users: users });
})

userRouter.post("/api/create", async (req, res) => {
   const payload = {
      name: "Smith",
      username: "smith78",
      email: "smithblake@gmail.com",
      phone: "1-750-736-3031 x51442"
   }
   const user = await createUser(payload);
   res.json({ user: user });
})