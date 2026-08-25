import 'dart:math' as math;

/// Ephemeral camera state for a running virtual-tour session.
///
/// This deliberately has no dependency on Flutter or model-viewer so the
/// editor preview and exported runtime can follow the same movement rules.
class ModelTourPose {
  const ModelTourPose({
    required this.theta,
    required this.phi,
    required this.x,
    required this.y,
    required this.z,
  });

  final double theta;
  final double phi;
  final double x;
  final double y;
  final double z;

  ModelTourPose copyWith({
    double? theta,
    double? phi,
    double? x,
    double? y,
    double? z,
  }) =>
      ModelTourPose(
        theta: theta ?? this.theta,
        phi: phi ?? this.phi,
        x: x ?? this.x,
        y: y ?? this.y,
        z: z ?? this.z,
      );
}

/// Axis-aligned safe walk area derived from the loaded model footprint.
class ModelTourBounds {
  const ModelTourBounds({
    required this.minX,
    required this.maxX,
    required this.minZ,
    required this.maxZ,
    required this.groundY,
  });

  final double minX;
  final double maxX;
  final double minZ;
  final double maxZ;
  final double groundY;

  ModelTourPose constrain(ModelTourPose pose) => pose.copyWith(
        x: pose.x.clamp(minX, maxX).toDouble(),
        y: groundY,
        z: pose.z.clamp(minZ, maxZ).toDouble(),
      );
}

class ModelTourRuntime {
  const ModelTourRuntime._();

  static const double minPhi = 42;
  static const double maxPhi = 89;

  static ModelTourPose look(ModelTourPose pose, {
    required double horizontalPixels,
    required double verticalPixels,
  }) {
    final theta = (pose.theta - horizontalPixels.clamp(-48, 48) * .24) % 360;
    return pose.copyWith(
      theta: theta < 0 ? theta + 360 : theta,
      phi: (pose.phi + verticalPixels.clamp(-48, 48) * .20)
          .clamp(minPhi, maxPhi)
          .toDouble(),
    );
  }

  static ModelTourPose move(ModelTourPose pose, {
    required double forwardMeters,
    required double rightMeters,
    ModelTourBounds? bounds,
  }) {
    final theta = pose.theta * math.pi / 180;
    final next = pose.copyWith(
      x: pose.x - forwardMeters * math.sin(theta) + rightMeters * math.cos(theta),
      z: pose.z - forwardMeters * math.cos(theta) - rightMeters * math.sin(theta),
    );
    return bounds?.constrain(next) ?? next;
  }

  static ModelTourBounds boundsFromModel({
    required double centerX,
    required double centerY,
    required double centerZ,
    required double width,
    required double height,
    required double depth,
  }) {
    // Keep a small inset so walking never puts the target exactly on a model
    // edge. Very small assets still expose a usable 0.25 m square.
    final insetX = math.min(width * .08, .75);
    final insetZ = math.min(depth * .08, .75);
    final halfX = math.max(.125, width / 2 - insetX);
    final halfZ = math.max(.125, depth / 2 - insetZ);
    return ModelTourBounds(
      minX: centerX - halfX,
      maxX: centerX + halfX,
      minZ: centerZ - halfZ,
      maxZ: centerZ + halfZ,
      groundY: centerY - height / 2,
    );
  }
}
