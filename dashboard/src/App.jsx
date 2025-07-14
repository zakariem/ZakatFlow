import React from "react";
import { Routes, Route, Navigate, Outlet } from "react-router-dom";
import Sidebar from "./components/Sidebar";
import Overview from "./components/Overview";
import PaymentManagement from "./components/PaymentManagement";
import AgentManagement from "./components/AgentManagement";
import AddAgent from "./components/AddAgent";
import EditAgent from "./components/EditAgent";
import Signup from "./components/Signup";
import LandingPage from "./components/LandingPage";
import NotFound from "./components/NotFound";
import { dashboardColors } from "./theme/dashboardColors";

// PrivateRoute component to protect dashboard routes
function PrivateRoute({ children }) {
  const token = localStorage.getItem("authToken");
  return token ? children : <Navigate to="/login" replace />;
}

// Dashboard Layout component
function DashboardLayout() {
  return (
    <div className="min-h-screen" style={{ backgroundColor: dashboardColors.background.light }}>
      <Sidebar />
      <main className="lg:ml-72 min-h-screen transition-all duration-300">
        <div className="p-4 lg:p-8 pt-20 lg:pt-8">
          <div className="max-w-7xl mx-auto">
            <Outlet />
          </div>
        </div>
      </main>
    </div>
  );
}

function App() {
  return (
    <Routes>
      {/* Public routes */}
      <Route path="/" element={<LandingPage />} />
      <Route path="/login" element={<Signup />} />
      {/* Protected dashboard routes */}
      <Route path="/dashboard" element={
        <PrivateRoute>
          <DashboardLayout />
        </PrivateRoute>
      }>
        <Route index element={<Overview />} />
        <Route path="paymentManagement" element={<PaymentManagement />} />
        <Route path="agent-management" element={<AgentManagement />} />
        <Route path="add-agent" element={<AddAgent />} />
        <Route path="edit-agent/:id" element={<EditAgent />} />
        {/* Catch-all route for dashboard 404s */}
        <Route path="*" element={<NotFound />} />
      </Route>
      {/* Catch-all route for general 404s */}
      <Route path="*" element={<NotFound />} />
    </Routes>
  );
}

export default App;
