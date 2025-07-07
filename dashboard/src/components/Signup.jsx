import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { adminApi } from "../api/adminApi";
import { dashboardColors } from "../theme/dashboardColors";

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
      const response = await axios.post(adminApi.loginUser, form);
      if (response.data) {
        localStorage.setItem('authToken', response.data.data.token);
        navigate("/dashboard");
      } else {
        setError("Login failed: Invalid response from server.");
      }
    } catch (err) {
      const message = err.response?.data?.message || "Login failed. Please check your credentials and try again.";
      setError(message);
      console.error("Login failed", err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center px-4 py-12 bg-gradient-to-br from-yellow-50 to-yellow-100">
      <div className="w-full max-w-md space-y-8 animate-fadeIn">
        {/* Logo Section */}
        <div className="text-center space-y-6">
          <div className="relative inline-block group">
            <div 
              className="w-28 h-28 rounded-full flex items-center justify-center shadow-2xl border-4 border-yellow-200 bg-gradient-to-br from-yellow-400 via-yellow-600 to-yellow-800 mx-auto mb-2 animate-fadeIn"
              style={{ boxShadow: dashboardColors.shadow.xl }}
            >
              <img src="/logo.png" alt="ZakatFlow Logo" className="w-20 h-20 object-contain" />
            </div>
          </div>
          <h2 
            className="text-4xl font-extrabold tracking-tight bg-gradient-to-r from-yellow-700 via-yellow-600 to-yellow-400 bg-clip-text text-transparent drop-shadow-lg"
          >
            Welcome to ZakatFlow
          </h2>
          <p className="text-lg font-medium" style={{ color: dashboardColors.text.secondary }}>
            Sign in to manage your Zakat operations
          </p>
        </div>

        {/* Form Section */}
        <div 
          className="p-8 rounded-2xl shadow-xl backdrop-blur-sm border-2 border-yellow-100 bg-gradient-to-br from-yellow-50 via-white to-yellow-100 animate-slideUp"
          style={{ 
            background: 'linear-gradient(135deg, #FFFDE4 0%, #FFF6B7 100%)',
            boxShadow: dashboardColors.shadow.xl
          }}
        >
          {error && (
            <div 
              className="p-4 mb-6 rounded-lg text-sm animate-shake"
              style={{ 
                backgroundColor: `${dashboardColors.status.error}15`,
                color: dashboardColors.status.error,
                border: `1px solid ${dashboardColors.status.error}30`
              }}
            >
              <div className="flex items-center">
                <svg className="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
                </svg>
                {error}
              </div>
            </div>
          )}

          <form className="space-y-6" onSubmit={handleSubmit}>
            <div>
              <label 
                htmlFor="email" 
                className="block text-sm font-medium"
                style={{ color: dashboardColors.text.primary }}
              >
                Email Address
              </label>
              <div className="mt-1">
                <input
                  id="email"
                  name="email"
                  type="email"
                  required
                  value={form.email}
                  onChange={handleChange}
                  className="block w-full px-4 py-3 rounded-lg transition duration-150 ease-in-out focus:ring-2 focus:ring-offset-2"
                  style={{
                    backgroundColor: dashboardColors.background.light,
                    border: `1px solid ${dashboardColors.border.light}`,
                    color: dashboardColors.text.primary,
                  }}
                  placeholder="admin@zakatflow.com"
                />
              </div>
            </div>

            <div>
              <label 
                htmlFor="password" 
                className="block text-sm font-medium"
                style={{ color: dashboardColors.text.primary }}
              >
                Password
              </label>
              <div className="mt-1 relative">
                <input
                  id="password"
                  name="password"
                  type={showPassword ? "text" : "password"}
                  required
                  value={form.password}
                  onChange={handleChange}
                  className="block w-full px-4 py-3 rounded-lg transition duration-150 ease-in-out focus:ring-2 focus:ring-offset-2"
                  style={{
                    backgroundColor: dashboardColors.background.light,
                    border: `1px solid ${dashboardColors.border.light}`,
                    color: dashboardColors.text.primary,
                  }}
                  placeholder="Enter your password"
                />
                <button
                  type="button"
                  onClick={handleShowPassword}
                  className="absolute inset-y-0 right-0 flex items-center pr-3 transition-colors duration-150"
                  style={{ color: dashboardColors.text.secondary }}
                >
                  {showPassword ? (
                    <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                    </svg>
                  ) : (
                    <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L3 3m6.878 6.878L21 21" />
                    </svg>
                  )}
                </button>
              </div>
            </div>

            <div>
              <button
                type="submit"
                disabled={loading}
                className="w-full flex justify-center py-3 px-4 rounded-lg text-white font-medium transition duration-150 ease-in-out transform hover:scale-105 focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
                style={{
                  background: dashboardColors.gradient.primary,
                  boxShadow: dashboardColors.shadow.md,
                }}
              >
                {loading ? (
                  <>
                    <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Signing in...
                  </>
                ) : (
                  'Sign in'
                )}
              </button>
            </div>
          </form>
        </div>

        {/* Footer */}
        <p className="text-center text-sm" style={{ color: dashboardColors.text.secondary }}>
          Protected by enterprise-grade security
        </p>
      </div>
    </div>
  );
};

export default Login;