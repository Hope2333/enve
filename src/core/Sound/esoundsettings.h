// enve - 2D animations software
// Copyright (C) 2016-2020 Maurycy Liebner

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#ifndef ESOUNDSETTINGS_H
#define ESOUNDSETTINGS_H

#include <QObject>
extern "C" {
    #include <libavutil/samplefmt.h>
    #include <libavutil/channel_layout.h>
    #include <libavutil/version.h>
}

#include "../core_global.h"

// FFmpeg 6.x compatibility: AVChannelLayout has nb_channels field
#if LIBAVUTIL_VERSION_INT >= AV_VERSION_INT(57, 49, 100)
#define ENVE_AV_GET_CHANNEL_LAYOUT_NB_CHANNELS(layout) \
    ((layout).nb_channels)
#else
#define ENVE_AV_GET_CHANNEL_LAYOUT_NB_CHANNELS(layout) \
    av_get_channel_layout_nb_channels(layout)
#endif

struct CORE_EXPORT eSoundSettingsData {
    int fSampleRate = 44100;
    AVSampleFormat fSampleFormat = AV_SAMPLE_FMT_FLT;
#if LIBAVUTIL_VERSION_INT >= AV_VERSION_INT(57, 49, 100)
    AVChannelLayout fChannelLayout;
    eSoundSettingsData() {
        av_channel_layout_default(&fChannelLayout, 2); // Stereo
    }
#else
    uint64_t fChannelLayout = AV_CH_LAYOUT_STEREO;
#endif

    bool planarFormat() const {
        return av_sample_fmt_is_planar(fSampleFormat);
    }

    int channelCount() const {
        return ENVE_AV_GET_CHANNEL_LAYOUT_NB_CHANNELS(fChannelLayout);
    }

    int bytesPerSample() const {
        return av_get_bytes_per_sample(fSampleFormat);
    }

    bool operator==(const eSoundSettingsData &other) const {
#if LIBAVUTIL_VERSION_INT >= AV_VERSION_INT(57, 49, 100)
        return fSampleRate == other.fSampleRate &&
               fSampleFormat == other.fSampleFormat &&
               av_channel_layout_compare(&fChannelLayout, &other.fChannelLayout) == 0;
#else
        return fSampleRate == other.fSampleRate &&
               fSampleFormat == other.fSampleFormat &&
               fChannelLayout == other.fChannelLayout;
#endif
    }
};

class CORE_EXPORT eSoundSettings : public QObject, private eSoundSettingsData {
    Q_OBJECT
public:
    eSoundSettings();

    static eSoundSettings* sInstance;

    static int sSampleRate();
    static AVSampleFormat sSampleFormat();
    static uint64_t sChannelLayout();
    static bool sPlanarFormat();
    static int sChannelCount();
    static int sBytesPerSample();
    static eSoundSettingsData &sData();

    static void sSetSampleRate(const int sampleRate);
    static void sSetSampleFormat(const AVSampleFormat format);
    static void sSetChannelLayout(const uint64_t layout);

    static void sSave();
    static void sRestore();

    void save();
    void restore();

    void setAll(const eSoundSettingsData& data);
    void setSampleRate(const int sampleRate);
    void setSampleFormat(const AVSampleFormat format);
    void setChannelLayout(const uint64_t layout);
private:
    using eSoundSettingsData::operator=;
    eSoundSettingsData mSaved;
signals:
    void settingsChanged();
};

#endif // ESOUNDSETTINGS_H
