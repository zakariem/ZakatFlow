import React, { useState, useEffect } from 'react';
import axios from 'axios';
import {adminApi} from '../api/adminApi';
import Sidebar from './Sidebar';



function Analytics() {
  const [analytics, setAnalytics] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchAnalytics = async () => {
      try {
        const response = await axios.get(adminApi.getAnalytics); // Assuming you have an analytics endpoint
        setAnalytics(response.data);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchAnalytics();
  }, []);

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error: {error}</p>;
  if (!analytics) return <p>No analytics data available.</p>;

  return (
    <div className="flex min-h-screen bg-[#F4F6FA]">
      <Sidebar />
      <main className="flex-1 ml-56 p-6">
        <h1 className="text-2xl font-semibold mb-6">Analytics</h1>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          {/* Payment Methods Chart */}
          <div className="bg-white rounded-xl shadow-sm p-6 flex flex-col items-center">
            <span className="font-medium mb-2">Payment Methods</span>
            <div className="relative flex items-center justify-center w-40 h-40">
              <svg width="160" height="160" viewBox="0 0 160 160">
                <circle cx="80" cy="80" r="70" fill="#F5F7FA" />
                <circle
                  cx="80"
                  cy="80"
                  r="70"
                  fill="none"
                  stroke="#2196F3"
                  strokeWidth="20"
                  strokeDasharray={440}
                  strokeDashoffset={110}
                  strokeLinecap="round"
                />
              </svg>
              <span className="absolute text-2xl font-bold text-blue-600">
                {analytics.paymentMethods}
              </span>
            </div>
          </div>
          {/* Daily Payments Chart */}
          <div className="bg-white rounded-xl shadow-sm p-6 flex flex-col items-center">
            <span className="font-medium mb-2">Daily Payments</span>
            <svg width="160" height="100" viewBox="0 0 160 100">
              <polyline
                fill="none"
                stroke="#2196F3"
                strokeWidth="4"
                points={analytics.dailyPayments.map((p, i) => `${i * 25},${100 - p * 5}`).join(' ')}
              />
              <rect x="0" y="90" width="160" height="10" fill="#F5F7FA" />
            </svg>
          </div>
        </div>
        <div>
          <h2 className="text-lg font-semibold mb-4">Top Performing Agents</h2>
          <div className="space-y-3">
            {analytics.topAgents.map((agent, idx) => (
              <div
                key={agent.name}
                className="flex items-center bg-white rounded-xl shadow-sm p-4"
              >
                <div className="w-10 h-10 flex items-center justify-center rounded-full bg-blue-100 text-blue-600 font-bold mr-4">
                  {idx + 1}
                </div>
                <div className="flex-1">
                  <div className="font-medium">{agent.name}</div>
                  <div className="text-xs text-gray-500">
                    {agent.payments} payments
                  </div>
                </div>
                <div className="font-semibold text-gray-700">
                  ${agent.amount.toFixed(2)}
                </div>
              </div>
            ))}
          </div>
        </div>
      </main>
    </div>
  );
}

export default Analytics;
