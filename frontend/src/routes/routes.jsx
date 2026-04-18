import LayoutPublic  from "../Layouts/LayoutPublic";
import Login from "../pages/Login";
import Register from "../pages/Register";
import UserList from "../pages/UserList";

export const routeData = () => {
    return [
       { path: "/",
         element: <LayoutPublic/>,
         children: [ { path: "login", element: <Login/> }, { path: "register", element: <Register/> }, { path: "users", element: <UserList/> }]
       }
    ]
};