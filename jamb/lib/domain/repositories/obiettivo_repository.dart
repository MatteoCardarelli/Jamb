import '../../domain/entities/obiettivo.dart';

abstract class IObiettivoRepository {
  Future<List<Obiettivo>> getObiettivi();
  Future<void> salvaObiettivo(Obiettivo obiettivo);
}
