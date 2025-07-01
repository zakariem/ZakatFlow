import React, { useState, useEffect } from "react";
import axios from "axios";
import { adminApi } from "../api/adminApi";

const Overview = () => {
  const [payments, setPayments] = useState([]);
  const [agents, setAgents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [paymentsRes, agentsRes] = await Promise.all([
          axios.get(adminApi.getPayments, {
            headers: { 'Authorization': `Bearer ${localStorage.getItem('authToken')}` }
          }),
          axios.get(adminApi.getAgents, {
            headers: { 'Authorization': `Bearer ${localStorage.getItem('authToken')}` }
          })
        ]);
        let paymentsData = paymentsRes.data;
        let agentsData = agentsRes.data;
        setPayments(Array.isArray(paymentsData) ? paymentsData : paymentsData.data || []);
        setAgents(Array.isArray(agentsData) ? agentsData : agentsData.data || []);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  // Calculate summary values
  const totalPayments = payments.length;
  const totalAmount = payments.reduce((sum, p) => sum + (parseFloat(p.amount) || 0), 0);
  const today = new Date();
  const todaysPayments = payments.filter(p => {
    const paidAt = new Date(p.paidAt || p.date);
    return paidAt.getFullYear() === today.getFullYear() &&
      paidAt.getMonth() === today.getMonth() &&
      paidAt.getDate() === today.getDate();
  });
  const todaysPaymentsCount = todaysPayments.length;
  const todaysAmount = todaysPayments.reduce((sum, p) => sum + (parseFloat(p.amount) || 0), 0);

  // Top agents by number of payments (or by totalDonation if available)
  const agentPaymentCounts = {};
  payments.forEach(p => {
    if (p.agent) {
      agentPaymentCounts[p.agent] = (agentPaymentCounts[p.agent] || 0) + 1;
    }
  });
  const topAgents = agents
    .map(agent => ({
      ...agent,
      paymentCount: agentPaymentCounts[agent.fullName] || 0
    }))
    .sort((a, b) => b.paymentCount - a.paymentCount)
    .slice(0, 3);

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error: {error}</p>;

  return (
    <>
      <div className="flex items-center justify-between mb-4">
        <h1 className="text-2xl font-semibold">Admin Dashboard</h1>
      </div>
      <h2 className="text-xl font-bold mb-4">Overview</h2>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-8">
        <div className="bg-white rounded-xl p-6 flex items-center gap-4 shadow">
          <div className="bg-blue-100 rounded-full p-3">
            <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><rect width="20" height="14" x="2" y="5" rx="2"/><path d="M2 10h20"/></svg>
          </div>
          <div>
            <div className="text-2xl font-bold">{totalPayments}</div>
            <div className="text-gray-500 text-sm">Total Payments</div>
          </div>
        </div>
        <div className="bg-white rounded-xl p-6 flex items-center gap-4 shadow">
          <div className="bg-green-100 rounded-full p-3">
            <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><text x="6" y="18" fontSize="14" fill="#34D399">$</text></svg>
          </div>
          <div>
            <div className="text-2xl font-bold">${totalAmount.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</div>
            <div className="text-gray-500 text-sm">Total Amount</div>
          </div>
        </div>
        <div className="bg-white rounded-xl p-6 flex items-center gap-4 shadow">
          <div className="bg-orange-100 rounded-full p-3">
            <svg className="w-6 h-6 text-orange-500" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><rect width="20" height="14" x="2" y="5" rx="2"/><path d="M2 10h20"/></svg>
          </div>
          <div>
            <div className="text-2xl font-bold">{todaysPaymentsCount}</div>
            <div className="text-gray-500 text-sm">Today's Payments</div>
          </div>
        </div>
        <div className="bg-white rounded-xl p-6 flex items-center gap-4 shadow">
          <div className="bg-purple-100 rounded-full p-3">
            <svg className="w-6 h-6 text-purple-500" fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24"><path d="M4 17l6-6 4 4 6-6"/></svg>
          </div>
          <div>
            <div className="text-2xl font-bold">${todaysAmount.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</div>
            <div className="text-gray-500 text-sm">Today's Amount</div>
          </div>
        </div>
      </div>
      <h2 className="text-lg font-bold mb-2">Top Agents</h2>
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
        {[...topAgents]
          .sort((a, b) => b.totalDonation - a.totalDonation)
          .map((agent, idx) => (
            <div key={agent._id || agent.id || idx} className="bg-white rounded-xl p-6 flex items-center gap-4 shadow">
              <div className="w-12 h-12 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 font-bold text-xl overflow-hidden">
                {agent.profileImage || agent.profileImageUrl || agent.image ? (
                  <img
                    src={agent.profileImage || agent.profileImageUrl || agent.image}
                    alt={agent.fullName}
                    className="w-full h-full object-cover rounded-full"
                  />
                ) : (
                  agent.fullName ? agent.fullName.charAt(0).toUpperCase() : '?'
                )}
              </div>
              <div>
                <div className="font-semibold">{agent.fullName}</div>
                <div className="text-gray-500 text-sm">Payments: {agent.totalDonation}</div>
              </div>
            </div>
          ))}
      </div>
    </>
  );
};

export default Overview;