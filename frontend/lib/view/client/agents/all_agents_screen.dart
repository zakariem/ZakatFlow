import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/agent_model.dart';
import '../../../providers/auth_providers.dart';
import '../../../utils/theme/app_color.dart';
import '../../../utils/widgets/loader.dart';
import '../../../viewmodels/agent_view_model.dart';
import 'agent_detail_screen.dart';

class AllAgentsScreen extends ConsumerStatefulWidget {
  const AllAgentsScreen({super.key});

  @override
  ConsumerState<AllAgentsScreen> createState() => _AllAgentsScreenState();
}

class _AllAgentsScreenState extends ConsumerState<AllAgentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAgents());
  }

  void _loadAgents() {
    final authState = ref.read(authViewModelProvider);
    final agentViewModel = ref.read(agentViewModelProvider);
    final token = authState.user?.token;
    if (token != null) {
      agentViewModel.loadAgents(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final agentViewModel = ref.watch(agentViewModelProvider);
    final agents = agentViewModel.agents;
    final isLoading = agentViewModel.isLoading;
    final error = agentViewModel.error;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Dhammaan Hay\'adaha',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(child: Loader())
              : error != null
              ? _buildErrorState(error)
              : agents.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh: () async => _loadAgents(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: agents.length,
                    itemBuilder:
                        (context, index) => _buildAgentCard(agents[index]),
                  ),
                ),
              ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Khalad ayaa dhacay',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: TextStyle(color: AppColors.textGray, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAgents,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.textWhite,
            ),
            child: const Text('Isku day mar kale'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_outlined, size: 80, color: AppColors.textGray),
          const SizedBox(height: 16),
          Text(
            'Hay\'ad lama helin',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hadda hay\'ad lama diiwaangelin',
            style: TextStyle(color: AppColors.textGray, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard(Agent agent) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AgentDetailScreen(agentId: agent.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              _buildBackground(agent),
              _buildGradientOverlay(),
              _buildAgentInfo(agent),
              _buildArrowIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(Agent agent) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image:
            agent.profileImageUrl != null
                ? DecorationImage(
                  image: NetworkImage(agent.profileImageUrl!),
                  fit: BoxFit.cover,
                )
                : null,
        color: agent.profileImageUrl == null ? AppColors.accentLightGold : null,
      ),
      child:
          agent.profileImageUrl == null
              ? Center(
                child: Icon(
                  Icons.business,
                  size: 50,
                  color: AppColors.textSecondary,
                ),
              )
              : null,
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
        ),
      ),
    );
  }

  Widget _buildAgentInfo(Agent agent) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              agent.fullName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentLightGold.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                agent.role,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowIndicator() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
