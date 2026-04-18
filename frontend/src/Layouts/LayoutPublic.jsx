import { Outlet } from "react-router-dom";
import NavbarPublic from "../Navbars/NavbarPublic";

const LayoutPublic = () => {
    return (
        <>
           <NavbarPublic/>
           <Outlet/>
        </>
    )
}

export default LayoutPublic;