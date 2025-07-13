import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { adminApi } from "../api/adminApi";
import { dashboardColors } from "../theme/dashboardColors";

const Signup = () => {
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
      // Handle specific error cases
      if (err.response?.status === 409 && err.response?.data?.error === 'ALREADY_LOGGED_IN') {
        setError(err.response.data.message || 'Account is already logged in elsewhere.');
        // You could show a dialog here to ask if they want to force logout
        // For now, just show the error message
      } else {
        const message = err.response?.data?.message || "Login failed. Please check your credentials and try again.";
        setError(message);
      }
      console.error("Login failed", err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8 relative overflow-hidden" 
         style={{ background: `linear-gradient(135deg, ${dashboardColors.background.main} 0%, ${dashboardColors.primary.cream} 50%, ${dashboardColors.background.light} 100%)` }}>
      
      {/* Animated Background Elements */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute top-20 left-20 w-32 h-32 rounded-full animate-pulse" style={{ backgroundColor: dashboardColors.primary.lightGold, animationDelay: '0s' }}></div>
        <div className="absolute top-40 right-32 w-24 h-24 rounded-full animate-pulse" style={{ backgroundColor: dashboardColors.primary.gold, animationDelay: '2s' }}></div>
        <div className="absolute bottom-32 left-1/4 w-20 h-20 rounded-full animate-pulse" style={{ backgroundColor: dashboardColors.primary.darkGold, animationDelay: '1s' }}></div>
        <div className="absolute bottom-20 right-20 w-28 h-28 rounded-full animate-pulse" style={{ backgroundColor: dashboardColors.primary.lightGold, animationDelay: '3s' }}></div>
      </div>
      
      <div className="relative z-10 max-w-md w-full space-y-8">
        {/* Enhanced Logo Section */}
        <div className="text-center space-y-6">
          <div className="relative group">
            <div className="w-24 h-24 mx-auto mb-6 rounded-3xl flex items-center justify-center transition-all duration-300 group-hover:scale-110 group-hover:rotate-3" 
                 style={{ 
                   background: dashboardColors.gradient.primary,
                   boxShadow: dashboardColors.shadow.lg
                 }}>
              <img src="/logo.png" alt="ZakatFlow Logo" className="w-16 h-16 object-contain transition-transform duration-300 group-hover:scale-110" />
            </div>
            <div className="absolute -top-2 -right-2 w-6 h-6 rounded-full flex items-center justify-center" style={{ backgroundColor: dashboardColors.status.success }}>
              <span className="text-xs text-white font-bold">✓</span>
            </div>
          </div>
          
          <h2 className="text-4xl font-bold mb-3" style={{ color: dashboardColors.text.primary }}>
            Welcome Back
          </h2>
          <p className="text-lg" style={{ color: dashboardColors.text.secondary }}>
            Sign in to your <span className="font-semibold" style={{ color: dashboardColors.primary.gold }}>ZakatFlow</span> account
          </p>
          
          {/* Trust indicators */}
          <div className="flex items-center justify-center gap-4 mt-4">
            <div className="flex items-center gap-1 text-xs" style={{ color: dashboardColors.text.muted }}>
              <div className="w-2 h-2 rounded-full" style={{ backgroundColor: dashboardColors.status.success }}></div>
              <span>Secure Login</span>
            </div>
            <div className="flex items-center gap-1 text-xs" style={{ color: dashboardColors.text.muted }}>
              <div className="w-2 h-2 rounded-full" style={{ backgroundColor: dashboardColors.status.success }}></div>
              <span>256-bit SSL</span>
            </div>
          </div>
        </div>

        {/* Enhanced Form Section */}
        <div className="bg-white rounded-3xl shadow-2xl p-10 border transition-all duration-300 hover:shadow-3xl" 
             style={{ 
               boxShadow: dashboardColors.shadow.xl,
               border: `1px solid ${dashboardColors.border.light}`
             }}>
          {error && (
            <div 
              className="mb-8 p-5 rounded-xl border-l-4 animate-shake transition-all duration-300"
              style={{ 
                backgroundColor: dashboardColors.status.error + '15',
                borderLeftColor: dashboardColors.status.error,
                color: dashboardColors.status.error
              }}
            >
              <div className="flex items-center">
                <div className="w-8 h-8 rounded-full flex items-center justify-center mr-3" style={{ backgroundColor: dashboardColors.status.error + '20' }}>
                  <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                  </svg>
                </div>
                <span className="font-medium">{error}</span>
              </div>
            </div>
          )}

          <form className="space-y-8" onSubmit={handleSubmit}>
            <div className="space-y-6">
              {/* Enhanced Email Field */}
              <div className="relative group">
                <label 
                  htmlFor="email" 
                  className="block text-sm font-semibold mb-3 transition-colors duration-200"
                  style={{ color: dashboardColors.text.primary }}
                >
                  Email Address
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none z-10">
                    <div className="w-8 h-8 rounded-lg flex items-center justify-center transition-all duration-300 group-hover:scale-110" 
                         style={{ backgroundColor: dashboardColors.primary.lightGold + '20' }}>
                      <svg className="w-4 h-4 transition-colors duration-200" fill="currentColor" viewBox="0 0 20 20" style={{ color: dashboardColors.primary.gold }}>
                        <path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z" />
                        <path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z" />
                      </svg>
                    </div>
                  </div>
                  <input
                    id="email"
                    name="email"
                    type="email"
                    autoComplete="email"
                    required
                    value={form.email}
                    onChange={handleChange}
                    className="block w-full pl-16 pr-4 py-4 border rounded-xl text-base placeholder-gray-400 focus:outline-none focus:ring-2 focus:border-transparent transition-all duration-300 bg-white hover:shadow-md"
                    style={{
                      borderColor: dashboardColors.border.light,
                      color: dashboardColors.text.primary,
                      boxShadow: dashboardColors.shadow.sm,
                      '--tw-ring-color': dashboardColors.primary.gold + '50'
                    }}
                    placeholder="Enter your email address"
                  />
                </div>
              </div>

              {/* Enhanced Password Field */}
              <div className="relative group">
                <label 
                  htmlFor="password" 
                  className="block text-sm font-semibold mb-3 transition-colors duration-200"
                  style={{ color: dashboardColors.text.primary }}
                >
                  Password
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none z-10">
                    <div className="w-8 h-8 rounded-lg flex items-center justify-center transition-all duration-300 group-hover:scale-110" 
                         style={{ backgroundColor: dashboardColors.primary.lightGold + '20' }}>
                      <svg className="w-4 h-4 transition-colors duration-200" fill="currentColor" viewBox="0 0 20 20" style={{ color: dashboardColors.primary.gold }}>
                        <path fillRule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clipRule="evenodd" />
                      </svg>
                    </div>
                  </div>
                  <input
                    id="password"
                    name="password"
                    type={showPassword ? "text" : "password"}
                    autoComplete="current-password"
                    required
                    value={form.password}
                    onChange={handleChange}
                    className="block w-full pl-16 pr-12 py-4 border rounded-xl text-base placeholder-gray-400 focus:outline-none focus:ring-2 focus:border-transparent transition-all duration-300 bg-white hover:shadow-md"
                    style={{
                      borderColor: dashboardColors.border.light,
                      color: dashboardColors.text.primary,
                      boxShadow: dashboardColors.shadow.sm,
                      '--tw-ring-color': dashboardColors.primary.gold + '50'
                    }}
                    placeholder="Enter your password"
                  />
                  <button
                    type="button"
                    onClick={handleShowPassword}
                    className="absolute inset-y-0 right-0 flex items-center pr-4 transition-all duration-300 hover:scale-110"
                    style={{ color: dashboardColors.text.secondary }}
                  >
                    <div className="w-8 h-8 rounded-lg flex items-center justify-center transition-all duration-300 hover:bg-gray-100">
                      {showPassword ? (
                        <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                        </svg>
                      ) : (
                        <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L3 3m6.878 6.878L21 21" />
                        </svg>
                      )}
                    </div>
                  </button>
                </div>
              </div>
</div>
            {/* Enhanced Submit Button */}
             <div className="pt-4">
               <button
                 type="submit"
                 disabled={loading}
                 className="group relative w-full flex justify-center items-center py-4 px-6 border border-transparent text-base font-semibold rounded-xl text-white transition-all duration-300 focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transform hover:scale-105 hover:shadow-xl active:scale-95"
                 style={{
                   background: dashboardColors.gradient.primary,
                   boxShadow: dashboardColors.shadow.lg,
                   '--tw-ring-color': dashboardColors.primary.gold + '50'
                 }}
               >
                 <div className="absolute inset-0 rounded-xl opacity-0 group-hover:opacity-20 transition-opacity duration-300" 
                      style={{ background: 'linear-gradient(45deg, rgba(255,255,255,0.3) 0%, transparent 100%)' }}></div>
                 
                 {loading ? (
                   <div className="flex items-center relative z-10">
                     <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin mr-3"></div>
                     <span>Signing you in...</span>
                   </div>
                 ) : (
                   <div className="flex items-center relative z-10">
                     <svg className="w-5 h-5 mr-2 transition-transform duration-300 group-hover:translate-x-1" fill="currentColor" viewBox="0 0 20 20">
                       <path fillRule="evenodd" d="M3 3a1 1 0 011 1v12a1 1 0 11-2 0V4a1 1 0 011-1zm7.707 3.293a1 1 0 010 1.414L9.414 9H17a1 1 0 110 2H9.414l1.293 1.293a1 1 0 01-1.414 1.414l-3-3a1 1 0 010-1.414l3-3a1 1 0 011.414 0z" clipRule="evenodd" />
                     </svg>
                     <span>Sign In to Dashboard</span>
                   </div>
                 )}
               </button>
               
               {/* Additional Security Info */}
               <div className="mt-6 text-center">
                 <div className="flex items-center justify-center gap-2 text-xs" style={{ color: dashboardColors.text.muted }}>
                   <svg className="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                     <path fillRule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clipRule="evenodd" />
                   </svg>
                   <span>Your data is protected with enterprise-grade security</span>
                 </div>
               </div>
             </div>
          </form>
        </div>

        {/* Enhanced Footer Section */}
        <div className="mt-8 text-center space-y-4">
          <div className="flex items-center justify-center gap-4">
            <div className="h-px flex-1" style={{ backgroundColor: dashboardColors.border.light }}></div>
            <span className="text-sm font-medium" style={{ color: dashboardColors.text.muted }}>Trusted Platform</span>
            <div className="h-px flex-1" style={{ backgroundColor: dashboardColors.border.light }}></div>
          </div>
          
          {/* Trust Badges */}
          <div className="flex items-center justify-center gap-6 py-4">
            <div className="flex items-center gap-2 text-xs" style={{ color: dashboardColors.text.muted }}>
              <div className="w-8 h-8 rounded-full flex items-center justify-center" style={{ backgroundColor: dashboardColors.primary.lightGold + '20' }}>
                <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20" style={{ color: dashboardColors.primary.gold }}>
                  <path fillRule="evenodd" d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                </svg>
              </div>
              <div>
                <div className="font-semibold">ISO Certified</div>
                <div className="text-xs opacity-75">Security Standards</div>
              </div>
            </div>
            
            <div className="flex items-center gap-2 text-xs" style={{ color: dashboardColors.text.muted }}>
              <div className="w-8 h-8 rounded-full flex items-center justify-center" style={{ backgroundColor: dashboardColors.primary.lightGold + '20' }}>
                <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20" style={{ color: dashboardColors.primary.gold }}>
                  <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                </svg>
              </div>
              <div>
                <div className="font-semibold">99.9% Uptime</div>
                <div className="text-xs opacity-75">Reliable Service</div>
              </div>
            </div>
          </div>
          
          {/* Links */}
          <div className="flex items-center justify-center gap-6 text-sm">
            <a href="#" className="transition-colors duration-200 hover:underline" style={{ color: dashboardColors.text.secondary }}>
              Need Help?
            </a>
            <span style={{ color: dashboardColors.border.medium }}>•</span>
            <a href="#" className="transition-colors duration-200 hover:underline" style={{ color: dashboardColors.text.secondary }}>
              Privacy Policy
            </a>
            <span style={{ color: dashboardColors.border.medium }}>•</span>
            <a href="#" className="transition-colors duration-200 hover:underline" style={{ color: dashboardColors.text.secondary }}>
              Terms of Service
            </a>
          </div>
          
          {/* Copyright */}
          <div className="pt-4 text-xs" style={{ color: dashboardColors.text.muted }}>
            © 2024 ZakatFlow. All rights reserved. | Empowering Zakat Management Worldwide
          </div>
        </div>
      </div>
    </div>
  );
};

export default Signup;