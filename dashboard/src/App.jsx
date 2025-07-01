import React from 'react';
import { Routes, Route, Navigate, Outlet } from 'react-router-dom';
import Sidebar from './components/Sidebar';
import Overview from './components/Overview';
import PaymentManagement from './components/PaymentManagement';
import Signup from './components/Signup';
import AgentManagement from './components/AgentManagement';
import AddAgent from './components/AddAgent';
import EditAgent from './components/EditAgent';

const isAuthenticated = () => {
  return localStorage.getItem('authToken') !== null;
};

const PrivateRoute = ({ children }) => {
  return isAuthenticated() ? <>{children}</> : <Navigate to="/signup" />;
};

const DashboardLayout = () => (
  <div className="flex min-h-screen" style={{ background: '#F4F6FA' }}>
    <Sidebar />
    <main className="flex-1 p-8 ml-64">
      <Outlet />
    </main>
  </div>
);

function App() {
  return (
    <Routes>
      <Route path="/" element={<div>Hello Word</div>} />
      <Route path="/signup" element={<Signup />} />
      <Route
        path="/dashboard/*"
        element={
          <PrivateRoute>
            <DashboardLayout />
          </PrivateRoute>
        }
      >
        <Route path="" element={<Overview />} />
        <Route path="paymentManagement" element={<PaymentManagement />} />
        <Route path="agent-management" element={<AgentManagement />} />
        <Route path="add-agent" element={<AddAgent />} />
        <Route path="edit-agent/:id" element={<EditAgent />} />
        
        {/* All agent and analytics routes removed */}
      </Route>
    </Routes>
  );
}

export default App;
