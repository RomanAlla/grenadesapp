import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grenadesapp/features/ai_chat/services/ai_service.dart';

final aiServiceProvider = Provider<AIService>((ref) => AIService()); 