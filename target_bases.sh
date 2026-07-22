BASE="/scratch/tmp/lterfehr/model_results"

RGB_TARGET_BASES=(
    "${BASE}/RGB_VST"
    "${BASE}/U-2-Net"
    "${BASE}/F3Net"
    "${BASE}/TRACER"
    "${BASE}/stdnet"
)

RGBD_TARGET_BASES=(
    "${BASE}/RGBD_VST"
    "${BASE}/CAVER"
    "${BASE}/SwinNet"
    "${BASE}/HFIL-Net"
    "${BASE}/SPNet"
)

BASES_COUNT="${#RGB_TARGET_BASES[@]}"