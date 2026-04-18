import { User } from "../models/user.js";

const getUsersFromApi = async () => {
    const response = await fetch("https://jsonplaceholder.typicode.com/users");
    
    if(!response.ok) {
        throw new Error(response.statusText)
    }
    const data = await response.json();
    return data;
}

export const insertUsers = async () => {
    const users = await getUsersFromApi();
    const modified = users.map((user) => {
        const { name, username, email, phone } = user;
        return {
            name: name,
            username: username,
            email: email,
            phone: phone
        }
    })
    const doc = await User.insertMany(modified);
    return doc;
}

export const createUser = async (payload) => {
    const { name, username, email, phone } = payload;
    const doc = await User.create({
        name: name,
        username: username,
        email: email,
        phone: phone
    })
    return doc;
}