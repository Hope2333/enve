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

#ifndef EFILTERSETTINGS_H
#define EFILTERSETTINGS_H

#include <QObject>

#include "core_global.h"
#include "skia/skiaincludes.h"
#include "simplemath.h"

class CORE_EXPORT eFilterSettings : public QObject {
    Q_OBJECT
public:
    eFilterSettings();

    static eFilterSettings* sInstance;

    static void sSetEnveRenderFilter(const SkSamplingOptions sampling) {
        sInstance->setEnveRenderFilter(sampling);
    }

    static void sSetOutputRenderFilter(const SkSamplingOptions sampling) {
        sInstance->setOutputRenderFilter(sampling);
    }

    static void sSetDisplayFilter(const SkSamplingOptions sampling) {
        sSetSmartDisplay(false);
        sInstance->mDisplayFilter = sampling;
    }

    static void sSetSmartDisplay(const bool smart) {
        sInstance->mSmartDisplay = smart;
    }

    static SkSamplingOptions sRender() {
        return sInstance->mRender;
    }

    static SkSamplingOptions sDisplay() {
        return sInstance->mDisplayFilter;
    }

    static bool sSmartDisplat() {
        return sInstance->mSmartDisplay;
    }

    static SkSamplingOptions sDisplay(const qreal zoom,
                                     const qreal resolution) {
        if(sInstance->mSmartDisplay) {
            const qreal scale = zoom/resolution;
            if(isOne4Dec(scale)) return SkSamplingOptions{SkFilterMode::kNearest};
            else if(scale > 2.5) return SkSamplingOptions{SkFilterMode::kNearest};
            else if(scale < 0.5) return SkSamplingOptions{SkFilterMode::kLinear, SkMipmapMode::kLinear};
            return SkSamplingOptions{SkFilterMode::kLinear, SkMipmapMode::kLinear};
        } else return sDisplay();
    }

    static void sSwitchToEnveRender() {
        sInstance->mCurrentRender = RenderFilter::enve;
        sInstance->updateRenderFilter();
    }

    static void sSwitchToOutputRender() {
        sInstance->mCurrentRender = RenderFilter::output;
        sInstance->updateRenderFilter();
    }

    void setEnveRenderFilter(const SkSamplingOptions sampling);
    void setOutputRenderFilter(const SkSamplingOptions sampling);
signals:
    void renderFilterChanged(const SkSamplingOptions sampling);
private:
    void updateRenderFilter() {
        SkSamplingOptions newFilter;
        if(mCurrentRender == RenderFilter::enve) newFilter = mEnveRender;
        else newFilter = mOutputRender;
        if(newFilter == mRender) return;
        mRender = newFilter;
        emit renderFilterChanged(newFilter);
    }

    SkSamplingOptions mEnveRender = SkSamplingOptions{SkFilterMode::kLinear, SkMipmapMode::kLinear};
    SkSamplingOptions mOutputRender = SkSamplingOptions{SkFilterMode::kLinear, SkMipmapMode::kLinear};

    enum class RenderFilter { enve, output };
    RenderFilter mCurrentRender = RenderFilter::enve;
    SkSamplingOptions mRender = mEnveRender;

    bool mSmartDisplay = true;
    SkSamplingOptions mDisplayFilter = SkSamplingOptions{SkFilterMode::kNearest};
};

#endif // EFILTERSETTINGS_H
