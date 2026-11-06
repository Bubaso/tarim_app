/// Sunum katmanının sağlayıcıya tek kapısı.
///
/// `providers/story_providers.dart` hem veri çekimini hem sıralamayı
/// barındırıyor; widget'ların oradan doğrudan içe aktarım yapması sunum
/// katmanını veri katmanının iç yapısına bağlıyordu. Tek satırlık bu köprü
/// bağımlılığı tek yerde tutuyor.
export '../providers/story_providers.dart' show storiesProvider;
