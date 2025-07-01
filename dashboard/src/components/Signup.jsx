import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { adminApi } from "../api/adminApi";
import dashboardColors from "../theme/dashboardColors";

// Renamed from Signup to Login for clarity
const Login = () => {
  const [showPassword, setShowPassword] = useState(false);
  const [form, setForm] = useState({ email: "", password: "" });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const navigate = useNavigate();

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleShowPassword = () => setShowPassword((prev) => !prev);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    
    try {
      // --- START: API Integration ---
      // Make a POST request to the login endpoint with user credentials
      const response = await axios.post(adminApi.loginUser, form);
      // Assuming the backend responds with a data object containing a token
      if (response.data) {
        // Store the token for future authenticated requests
        localStorage.setItem('authToken', response.data.data.token);
        
        // Navigate to the dashboard on successful login
        navigate("/dashboard");
      } else {
        // Handle unexpected response format from the server
        setError("Login failed: Invalid response from server.");
      }
      // --- END: API Integration ---

    } catch (err) {
      // Set error message from the server response, or a generic one
      const message = err.response?.data?.message || "Login failed. Please check your credentials and try again.";
      setError(message);
      console.error("Login failed", err);
    } finally {
      // Ensure the loading state is turned off
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center px-4 py-6 transition-all duration-500" 
         style={{ background: dashboardColors.gradient.secondary }}>
      <div className="w-full max-w-md animate-fadeIn">
        {/* Logo/Icon Section */}
        <div className="flex flex-col items-center mb-8">
          <div className="relative group">
            <div className="w-20 h-20 rounded-full flex items-center justify-center transition-all duration-300 group-hover:scale-110" 
                 style={{ background: dashboardColors.gradient.primary, boxShadow: dashboardColors.shadow.lg }}>
              <svg className="w-10 h-10 text-white" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
              </svg>
            </div>
          </div>
          <h1 className="text-3xl font-bold mt-4 mb-2" style={{ color: dashboardColors.text.primary }}>
            ZakatFlow Admin
          </h1>
          <p className="text-center" style={{ color: dashboardColors.text.secondary }}>
            Welcome back! Please sign in to your account.
          </p>
        </div>

        {/* Login Form */}
        <div className="bg-white rounded-2xl p-8 transition-all duration-300 hover:shadow-xl" 
             style={{ boxShadow: dashboardColors.shadow.md }}>
          {error && (
            <div className="mb-4 p-3 rounded-lg text-sm animate-shake" 
                 style={{ backgroundColor: '#FEE2E2', color: dashboardColors.status.error }}>
              {error}
            </div>
          )}
          
          <form className="space-y-6" onSubmit={handleSubmit}>
            <div className="space-y-1">
              <label className="text-sm font-medium" style={{ color: dashboardColors.text.primary }}>
                Email Address
              </label>
              <input 
                name="email" 
                type="email" 
                placeholder="admin@zakatflow.com" 
                value={form.email} 
                onChange={handleChange} 
                className="w-full px-4 py-3 rounded-lg border transition-all duration-200 focus:outline-none focus:ring-2" 
                style={{ 
                  borderColor: dashboardColors.border.light,
                  focusRingColor: dashboardColors.primary.gold 
                }}
                required
              />
            </div>
            
            <div className="space-y-1">
              <label className="text-sm font-medium" style={{ color: dashboardColors.text.primary }}>
                Password
              </label>
              <div className="relative">
                <input 
                  name="password" 
                  type={showPassword ? "text" : "password"} 
                  placeholder="Enter your password" 
                  value={form.password} 
                  onChange={handleChange} 
                  className="w-full px-4 py-3 rounded-lg border pr-12 transition-all duration-200 focus:outline-none focus:ring-2" 
                  style={{ 
                    borderColor: dashboardColors.border.light,
                    focusRingColor: dashboardColors.primary.gold 
                  }}
                  required
                />
                <button
                  type="button"
                  onClick={handleShowPassword}
                  className="absolute right-3 top-1/2 transform -translate-y-1/2 transition-colors duration-200 hover:opacity-70"
                  style={{ color: dashboardColors.primary.gold }}
                >
                  {showPassword ? (
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path strokeLinecap="round" strokeLinejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                  ) : (
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L3 3m6.878 6.878L21 21" /></svg>
                  )}
                </button>
              </div>
            </div>
            
            <button 
              type="submit" 
              disabled={loading}
              className="w-full py-3 px-4 rounded-lg text-white font-semibold transition-all duration-200 transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
              style={{ 
                background: loading ? dashboardColors.text.muted : dashboardColors.gradient.primary,
                boxShadow: dashboardColors.shadow.md 
              }}
            >
              {loading ? (
                <div className="flex items-center justify-center">
                  <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"><circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle><path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
                  Signing in...
                </div>
              ) : (
                'Sign In'
              )}
            </button>
          </form>
          
          <div className="mt-6 text-center">
            <p className="text-sm" style={{ color: dashboardColors.text.muted }}>
              Enter your admin credentials to continue.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;