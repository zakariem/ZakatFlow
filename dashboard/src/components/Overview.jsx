import React, { useState, useEffect } from "react";

const Overview = () => {
  const [overview, setOverview] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Mock data for overview
    setTimeout(() => {
      setOverview({
        totalPayments: 120,
        totalAmount: 15000.75,
        todaysPayments: 8,
        todaysAmount: 1200.5,
      });
      setLoading(false);
    }, 500);
  }, []);

  if (loading) return <p>Loading...</p>;
  if (!overview) return <p>No overview data available.</p>;

  return (
    <>
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
            <div className="text-2xl font-bold">${
              typeof overview.totalAmount === 'number' && !isNaN(overview.totalAmount)
                ? overview.totalAmount.toFixed(2)
                : '0.00'
            }</div>
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
            <div className="text-2xl font-bold">${
              typeof overview.todaysAmount === 'number' && !isNaN(overview.todaysAmount)
                ? overview.todaysAmount.toFixed(2)
                : '0.00'
            }</div>
            <div className="text-gray-500 text-sm">Today's Amount</div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Overview;