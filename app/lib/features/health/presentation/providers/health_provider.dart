import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../notifications/data/notification_repository.dart';
import '../../data/health_repository.dart';
import '../../data/medicine_repository.dart';

part 'health_provider.g.dart';

@Riverpod(keepAlive: true)
MedicineRepository medicineRepository(MedicineRepositoryRef ref) =>
    MedicineRepository(ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
HealthRepository healthRepository(HealthRepositoryRef ref) =>
    HealthRepository(ref.watch(databaseProvider));

@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(NotificationRepositoryRef ref) =>
    NotificationRepository(ref.watch(databaseProvider));

@riverpod
Stream<List<MedicineCabinetItem>> medicineCabinet(MedicineCabinetRef ref) =>
    ref.watch(medicineRepositoryProvider).watchCabinet();

@riverpod
Stream<List<MedicineEvent>> allMedicineEvents(AllMedicineEventsRef ref) =>
    ref.watch(medicineRepositoryProvider).watchAllTreatments();

@riverpod
Stream<List<TbTestEvent>> allTbTests(AllTbTestsRef ref) =>
    ref.watch(healthRepositoryProvider).watchAllTbTests();

@riverpod
Stream<List<HealthEvent>> allHealthEvents(AllHealthEventsRef ref) =>
    ref.watch(healthRepositoryProvider).watchAllHealthEvents();

@riverpod
Stream<List<AppNotification>> unreadNotifications(UnreadNotificationsRef ref) =>
    ref.watch(notificationRepositoryProvider).watchUnreadNotifications();

@riverpod
Stream<int> unreadCount(UnreadCountRef ref) =>
    ref.watch(unreadNotificationsProvider).when(
          data: (List<AppNotification> list) =>
              Stream.value(list.where((n) => !n.isRead).length),
          loading: () => Stream.value(0),
          error: (_, __) => Stream.value(0),
        );
