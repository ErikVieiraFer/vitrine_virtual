import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/errors/failures.dart';
import '../models/tenant_model.dart';
import '../models/service_model.dart';
import '../models/availability_model.dart';
import '../models/booking_model.dart';

class FirebaseDatasource {
  final FirebaseFirestore firestore;

  FirebaseDatasource({required this.firestore});

  Future<TenantModel> getTenantBySubdomain(String subdomain) async {
    try {
      developer.log(
        'Buscando tenant com subdomain: $subdomain',
        name: 'FirebaseDatasource',
      );

      final querySnapshot = await firestore
          .collection(FirebaseConstants.tenantsCollection)
          .where(FirebaseConstants.subdomainField, isEqualTo: subdomain)
          .limit(1)
          .get();

      developer.log(
        'Documentos encontrados: ${querySnapshot.docs.length}',
        name: 'FirebaseDatasource',
      );

      if (querySnapshot.docs.isEmpty) {
        developer.log(
          'ERRO: Tenant não encontrado para subdomain: $subdomain',
          name: 'FirebaseDatasource',
          level: 1000,
        );
        throw const NotFoundFailure('Tenant não encontrado');
      }

      final doc = querySnapshot.docs.first;
      developer.log(
        'Tenant encontrado: ID=${doc.id}',
        name: 'FirebaseDatasource',
      );
      return TenantModel.fromJson(doc.data(), doc.id);
    } on FirebaseException catch (e) {
      developer.log(
        '========================================',
        name: 'FirebaseDatasource',
        level: 1000,
      );
      developer.log(
        'ERRO FIREBASE DETECTADO',
        name: 'FirebaseDatasource',
        level: 1000,
      );
      developer.log(
        'Código: ${e.code}',
        name: 'FirebaseDatasource',
        level: 1000,
      );
      developer.log(
        'Mensagem completa:',
        name: 'FirebaseDatasource',
        level: 1000,
      );
      developer.log(
        e.message ?? 'Sem mensagem',
        name: 'FirebaseDatasource',
        level: 1000,
      );
      developer.log(
        '========================================',
        name: 'FirebaseDatasource',
        level: 1000,
      );
      throw ServerFailure(e.message ?? 'Erro ao buscar tenant');
    } catch (e, stackTrace) {
      developer.log(
        'ERRO INESPERADO: $e',
        name: 'FirebaseDatasource',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      rethrow;
    }
  }

  Future<List<ServiceModel>> getServicesByTenantId(String tenantId) async {
    try {
      final querySnapshot = await firestore
          .collection(FirebaseConstants.servicesCollection)
          .where(FirebaseConstants.tenantIdField, isEqualTo: tenantId)
          .where(FirebaseConstants.isActiveField, isEqualTo: true)
          .orderBy(FirebaseConstants.createdAtField, descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => ServiceModel.fromJson(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      developer.log(
        '========================================',
        name: 'FirebaseDatasource.getServices',
        level: 1000,
      );
      developer.log(
        'ERRO FIREBASE: ${e.code}',
        name: 'FirebaseDatasource.getServices',
        level: 1000,
      );
      developer.log(
        e.message ?? 'Sem mensagem',
        name: 'FirebaseDatasource.getServices',
        level: 1000,
      );
      developer.log(
        '========================================',
        name: 'FirebaseDatasource.getServices',
        level: 1000,
      );
      throw ServerFailure(e.message ?? 'Erro ao buscar serviços');
    }
  }

  Future<ServiceModel> getServiceById(String serviceId) async {
    try {
      final doc = await firestore
          .collection(FirebaseConstants.servicesCollection)
          .doc(serviceId)
          .get();

      if (!doc.exists) {
        throw const NotFoundFailure('Serviço não encontrado');
      }

      return ServiceModel.fromJson(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      developer.log(
        '========================================',
        name: 'FirebaseDatasource.getServiceById',
        level: 1000,
      );
      developer.log(
        'ERRO FIREBASE: ${e.code}',
        name: 'FirebaseDatasource.getServiceById',
        level: 1000,
      );
      developer.log(
        e.message ?? 'Sem mensagem',
        name: 'FirebaseDatasource.getServiceById',
        level: 1000,
      );
      developer.log(
        '========================================',
        name: 'FirebaseDatasource.getServiceById',
        level: 1000,
      );
      throw ServerFailure(e.message ?? 'Erro ao buscar serviço');
    }
  }

  Future<List<AvailabilityModel>> getAvailabilityByTenantAndDay({
    required String tenantId,
    required int dayOfWeek,
  }) async {
    try {
      final querySnapshot = await firestore
          .collection(FirebaseConstants.availabilityCollection)
          .where(FirebaseConstants.tenantIdField, isEqualTo: tenantId)
          .where(FirebaseConstants.dayOfWeekField, isEqualTo: dayOfWeek)
          .get();

      return querySnapshot.docs
          .map((doc) => AvailabilityModel.fromJson(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      developer.log(
        '========================================',
        name: 'FirebaseDatasource.getAvailability',
        level: 1000,
      );
      developer.log(
        'ERRO FIREBASE: ${e.code}',
        name: 'FirebaseDatasource.getAvailability',
        level: 1000,
      );
      developer.log(
        e.message ?? 'Sem mensagem',
        name: 'FirebaseDatasource.getAvailability',
        level: 1000,
      );
      developer.log(
        '========================================',
        name: 'FirebaseDatasource.getAvailability',
        level: 1000,
      );
      throw ServerFailure(e.message ?? 'Erro ao buscar disponibilidade');
    }
  }

  Future<List<BookingModel>> getBookingsByTenantAndDate({
    required String tenantId,
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await firestore
          .collection(FirebaseConstants.bookingsCollection)
          .where(FirebaseConstants.tenantIdField, isEqualTo: tenantId)
          .where(
            FirebaseConstants.bookingDateField,
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where(
            FirebaseConstants.bookingDateField,
            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
          )
          .where(
            FirebaseConstants.statusField,
            whereIn: [
              FirebaseConstants.statusPending,
              FirebaseConstants.statusConfirmed,
            ],
          )
          .get();

      return querySnapshot.docs
          .map((doc) => BookingModel.fromJson(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      developer.log(
        '========================================',
        name: 'FirebaseDatasource.getBookings',
        level: 1000,
      );
      developer.log(
        'ERRO FIREBASE: ${e.code}',
        name: 'FirebaseDatasource.getBookings',
        level: 1000,
      );
      developer.log(
        e.message ?? 'Sem mensagem',
        name: 'FirebaseDatasource.getBookings',
        level: 1000,
      );
      developer.log(
        '========================================',
        name: 'FirebaseDatasource.getBookings',
        level: 1000,
      );
      throw ServerFailure(e.message ?? 'Erro ao buscar agendamentos');
    }
  }

  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      final docRef = await firestore
          .collection(FirebaseConstants.bookingsCollection)
          .add(booking.toJson());

      final doc = await docRef.get();
      return BookingModel.fromJson(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      developer.log(
        '========================================',
        name: 'FirebaseDatasource.createBooking',
        level: 1000,
      );
      developer.log(
        'ERRO FIREBASE: ${e.code}',
        name: 'FirebaseDatasource.createBooking',
        level: 1000,
      );
      developer.log(
        e.message ?? 'Sem mensagem',
        name: 'FirebaseDatasource.createBooking',
        level: 1000,
      );
      developer.log(
        '========================================',
        name: 'FirebaseDatasource.createBooking',
        level: 1000,
      );
      throw ServerFailure(e.message ?? 'Erro ao criar agendamento');
    }
  }

  Future<bool> checkSlotAvailability({
    required String tenantId,
    required DateTime date,
    required String time,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot = await firestore
          .collection(FirebaseConstants.bookingsCollection)
          .where(FirebaseConstants.tenantIdField, isEqualTo: tenantId)
          .where(
            FirebaseConstants.bookingDateField,
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where(
            FirebaseConstants.bookingDateField,
            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
          )
          .where(FirebaseConstants.bookingTimeField, isEqualTo: time)
          .where(
            FirebaseConstants.statusField,
            whereIn: [
              FirebaseConstants.statusPending,
              FirebaseConstants.statusConfirmed,
            ],
          )
          .get();

      return querySnapshot.docs.isEmpty;
    } on FirebaseException catch (e) {
      developer.log(
        '========================================',
        name: 'FirebaseDatasource.checkSlot',
        level: 1000,
      );
      developer.log(
        'ERRO FIREBASE: ${e.code}',
        name: 'FirebaseDatasource.checkSlot',
        level: 1000,
      );
      developer.log(
        e.message ?? 'Sem mensagem',
        name: 'FirebaseDatasource.checkSlot',
        level: 1000,
      );
      developer.log(
        '========================================',
        name: 'FirebaseDatasource.checkSlot',
        level: 1000,
      );
      throw ServerFailure(e.message ?? 'Erro ao verificar disponibilidade');
    }
  }
}
