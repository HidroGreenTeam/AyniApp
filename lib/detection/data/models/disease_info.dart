class DiseaseInfo {
  final String id;
  final String name;
  final String description;
  final List<String> symptoms;
  final List<String> treatments;
  final String prevention;
  final String imageAsset;

  const DiseaseInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.symptoms,
    required this.treatments,
    required this.prevention,
    required this.imageAsset,
  });
}

class DiseaseRepository {
  static List<DiseaseInfo> getDiseases() {
    return [
      DiseaseInfo(
        id: 'miner',
        name: 'Leaf Miner',
        description: 'Los minadores de hojas son larvas de insectos que excavan túneles dentro de las hojas de las plantas, causando daños estéticos y reduciendo la capacidad fotosintética.',
        symptoms: [
          'Túneles sinuosos visibles en las hojas',
          'Manchas blancas o transparentes en el follaje',
          'Hojas con aspecto "marcado" o "rayado"',
          'Reducción en el crecimiento de la planta',
          'Hojas que se secan y caen prematuramente'
        ],
        treatments: [
          'Aplicar insecticidas sistémicos específicos para minadores',
          'Usar aceites hortícolas para sofocar las larvas',
          'Introducir enemigos naturales como avispas parasitarias',
          'Eliminar y destruir hojas infestadas',
          'Aplicar Bacillus thuringiensis (Bt) como control biológico'
        ],
        prevention: 'Mantener un buen control de malezas, usar trampas adhesivas amarillas, y aplicar tratamientos preventivos en épocas de alta incidencia.',
        imageAsset: 'assets/images/diseases/leaf_miner.png',
      ),
      DiseaseInfo(
        id: 'phoma',
        name: 'Phoma Leaf Spot',
        description: 'La mancha foliar por Phoma es una enfermedad fúngica que afecta principalmente a las hojas, causando lesiones circulares que pueden expandirse y causar defoliación.',
        symptoms: [
          'Manchas circulares marrones o negras en las hojas',
          'Lesiones con bordes bien definidos',
          'Centro de las manchas puede volverse gris o blanco',
          'Hojas que se secan desde los bordes hacia el centro',
          'Defoliación prematura en casos severos'
        ],
        treatments: [
          'Aplicar fungicidas a base de cobre o azufre',
          'Eliminar y destruir hojas infectadas',
          'Mejorar la circulación de aire entre plantas',
          'Evitar el riego por aspersión',
          'Aplicar tratamientos preventivos en épocas húmedas'
        ],
        prevention: 'Evitar el riego excesivo, mantener buena ventilación, y aplicar fungicidas preventivos durante períodos de alta humedad.',
        imageAsset: 'assets/images/diseases/phoma.png',
      ),
      DiseaseInfo(
        id: 'redspider',
        name: 'Red Spider Mite',
        description: 'Los ácaros rojos son pequeños arácnidos que se alimentan de la savia de las plantas, causando daños que pueden ser severos en condiciones de sequía.',
        symptoms: [
          'Puntos blancos o amarillos en las hojas',
          'Telarañas finas en el envés de las hojas',
          'Hojas que se vuelven bronceadas o rojizas',
          'Defoliación prematura',
          'Crecimiento atrofiado de la planta'
        ],
        treatments: [
          'Aplicar acaricidas específicos',
          'Usar aceites hortícolas para sofocar los ácaros',
          'Aumentar la humedad ambiental',
          'Introducir depredadores naturales como Phytoseiulus persimilis',
          'Lavar las hojas con agua jabonosa'
        ],
        prevention: 'Mantener alta humedad ambiental, evitar el estrés hídrico, y realizar inspecciones regulares para detectar infestaciones tempranas.',
        imageAsset: 'assets/images/diseases/red_spider.png',
      ),
      DiseaseInfo(
        id: 'rust',
        name: 'Leaf Rust',
        description: 'La roya de las hojas es una enfermedad fúngica que se caracteriza por la aparición de pústulas de color óxido en las hojas, tallos y frutos.',
        symptoms: [
          'Pústulas de color óxido, naranja o marrón en las hojas',
          'Manchas circulares con polvo de esporas',
          'Hojas que se secan y caen prematuramente',
          'Reducción en la producción de frutos',
          'Debilitamiento general de la planta'
        ],
        treatments: [
          'Aplicar fungicidas sistémicos específicos para royas',
          'Eliminar y destruir material vegetal infectado',
          'Mejorar la circulación de aire',
          'Evitar el riego por aspersión',
          'Aplicar tratamientos preventivos en épocas de riesgo'
        ],
        prevention: 'Usar variedades resistentes, mantener buena ventilación, evitar el riego excesivo y aplicar fungicidas preventivos.',
        imageAsset: 'assets/images/diseases/rust.png',
      ),
    ];
  }

  static DiseaseInfo? getDiseaseById(String id) {
    return getDiseases().firstWhere(
      (disease) => disease.id == id,
      orElse: () => throw Exception('Disease not found: $id'),
    );
  }
} 