import { Routes, Route, Navigate } from 'react-router-dom';
import Sidebar from './components/Sidebar';
import Overview from './components/Overview';
import PaymentManagement from './components/PaymentManagement';
import Analytics from './components/Analytics';
import AgentManagement from './components/AgentManagement';
import Signup from './components/Signup';
import EditAgent from './components/EditAgent';
import AddAgent from './components/AddAgent';

const isAuthenticated = () => {
  return localStorage.getItem('authToken') !== null;
};

const PrivateRoute = ({ children }) => {
  return isAuthenticated() ? <>{children}</> : <Navigate to="/signup" />;
};

function App() {
  return (
    <Routes>
      <Route path="/" element={<div>Hello Word</div>} />
      <Route path="/signup" element={<Signup />} />
      <Route
        path="/dashboard/*"
        element={
          <PrivateRoute>
            <div className="flex">
              <Sidebar />
              <main className="flex-1 p-6">
                <Routes>
                  <Route path="/" element={<Overview />} />
                  <Route path="/paymentManagement" element={<PaymentManagement />} />
                  <Route path="/analytics" element={<Analytics />} />
                  <Route path="/agent-management" element={<AgentManagement />} />
                  <Route path="/add-agent" element={<AddAgent />} />
                  <Route path="/edit-agent/:id" element={<EditAgent />} />
                </Routes>
              </main>
            </div>
          </PrivateRoute>
        }
      />
    </Routes>
  );
}

export default App;
