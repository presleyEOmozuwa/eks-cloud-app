import { Link } from 'react-router-dom'

const NavbarPublic = () => {
  return (
    <>
      <nav className='navbar navbar-expand-lg bg-dark m-1'>
        <div className='container-fluid'>
          <Link className='navbar-brand text-white' to='#'>Navbar</Link>
          <button className='navbar-toggler bg-light p-0 rounded-0' type='button' data-bs-toggle='collapse' data-bs-target='#navbarSupportedContent' aria-controls='navbarSupportedContent' aria-expanded='false' aria-label='Toggle navigation'>
            <span className='navbar-toggler-icon' />
          </button>
          <div className='collapse navbar-collapse' id='navbarSupportedContent'>
            <ul className='navbar-nav ms-auto me-auto mb-2 mb-lg-0'>
              <li className='nav-item'>
                <Link className='nav-link text-white' to='/'>Home</Link>
              </li>

              <li className='nav-item'>
                <Link data-testid='registerLink' className='nav-link text-white' to='/register'>Register</Link>
              </li>

              <li className='nav-item'>
                <Link className='nav-link text-white' to='/login'>Login</Link>
              </li>

              <li className='nav-item'>
                <Link className='nav-link text-white' to='/users'>Users</Link>
              </li>
            </ul>
          </div>
        </div>
      </nav>
    </>
  )
}

export default NavbarPublic