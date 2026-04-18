import { useState, useEffect } from 'react';
import axios from 'axios';

const UserList = () => {
    const [users, setUsers] = useState([])
    useEffect(() => {
        axios.get("/api/users").then((res) => {
            const { users } = res.data;
            console.log(users);
            setUsers(users);
        }).catch((err) => console.log(err.message));
    }, [])
    return (
        <>
            {users.map((user, index) => {
                const { name, username, email, phone } = user;
                return (
                    <div key={index} style={{backgroundColor: "navy", color: "white", fontSize: "large", textAlign: "justify", paddingLeft: "20px"}}>
                        <hr/>
                        <p className='p-0 m-0'> FirstName: {name}</p>
                        <p className='p-0 m-0'> UserName: {username}</p>
                        <p className='p-0 m-0'>Email: {email}</p>
                        <p className='p-0 m-0'>Phone: {phone}</p>
                        <hr/>
                    </div>
                )
            })}
        </>
    )
}

export default UserList;