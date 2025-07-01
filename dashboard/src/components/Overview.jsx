import React, { useState, useEffect } from "react";
import axios from "axios";
import { adminApi } from "../api/adminApi";
import Sidebar from "./Sidebar";

const Overview = () => {
  const [overview, setOverview] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchOverview = async () => {
      try {
        const response = await axios.get(adminApi.getOverview); // Assuming you have an overview endpoint
        setOverview(response.data);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchOverview();
  }, []);

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error: {error}</p>;
  if (!overview) return <p>No overview data available.</p>;

  return (
    <div className="flex min-h-screen bg-[#F4F6FA]">
      <Sidebar />
      <main className="flex-1 ml-56 p-6">
        <div className="flex items-center justify-between mb-4">
          <h1 className="text-2xl font-semibold">Admin Dashboard</h1>
          <button className="text-gray-400 hover:text-gray-600">
            <svg className="w-6 h-6" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" d="M4 4v16h16V4H4zm4 8h8" /></svg>
          </button>
        </div>
        <h2 className="text-xl font-bold mb-4">Overview</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div className="bg-white rounded-xl p-6 flex items-center gap-4 shadow">
            <div className="bg-blue-100 rounded-full p-3">
              <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><rect width="20" height="14" x="2" y="5" rx="2"/><path d="M2 10h20"/></svg>
            </div>
            <div>
              <div className="text-2xl font-bold">{overview.totalPayments}</div>
              <div className="text-gray-500 text-sm">Total Payments</div>
            </div>
          </div>
          <div className="bg-white rounded-xl p-6 flex items-center gap-4 shadow">
            <div className="bg-green-100 rounded-full p-3">
              <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><text x="6" y="18" fontSize="14" fill="#34D399">$</text></svg>
            </div>
            <div>
              <div className="text-2xl font-bold">${overview.totalAmount.toFixed(2)}</div>
              <div className="text-gray-500 text-sm">Total Amount</div>
            </div>
          </div>
          <div className="bg-white rounded-xl p-6 flex items-center gap-4 shadow">
            <div className="bg-orange-100 rounded-full p-3">
              <svg className="w-6 h-6 text-orange-500" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><rect width="20" height="14" x="2" y="5" rx="2"/><path d="M2 10h20"/></svg>
            </div>
            <div>
              <div className="text-2xl font-bold">{overview.todaysPayments}</div>
              <div className="text-gray-500 text-sm">Today's Payments</div>
            </div>
          </div>
          <div className="bg-white rounded-xl p-6 flex items-center gap-4 shadow">
            <div className="bg-purple-100 rounded-full p-3">
              <svg className="w-6 h-6 text-purple-500" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path d="M4 17l6-6 4 4 6-6"/></svg>
            </div>
            <div>
              <div className="text-2xl font-bold">${overview.todaysAmount.toFixed(2)}</div>
              <div className="text-gray-500 text-sm">Today's Amount</div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

export default Overview;