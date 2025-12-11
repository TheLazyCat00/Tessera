import 'package:tessera/tessera.dart';

AnimationFunc linear = (double progressRatio) {
	return progressRatio;
};

AnimationFunc ease = (double progressRatio) {
	if (progressRatio < 0.5) {
		return 2 * progressRatio * progressRatio;
	} else {
		return 1 - 2 * (1 - progressRatio) * (1 - progressRatio);
	}
};

AnimationFunc easeIn = (double progressRatio) {
	return progressRatio * progressRatio;
};

AnimationFunc easeOut = (double progressRatio) {
	return 1 - (1 - progressRatio) * (1 - progressRatio);
};
