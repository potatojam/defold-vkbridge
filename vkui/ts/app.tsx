/* eslint-disable camelcase */
import { AppRoot, ConfigProvider, AdaptivityProvider, PromoBanner, FixedLayout, Panel, View } from '@vkontakte/vkui';
import React from 'react';
import ReactDOM from 'react-dom';
import '@vkontakte/vkui/dist/vkui.css';

declare type BannerData = {
    title?: string;
    url_types?: string;
    bannerID?: string;
    imageWidth?: number;
    imageHeight?: number;
    imageLink?: string;
    trackingLink?: string;
    type?: string;
    iconWidth?: number;
    domain?: string;
    ctaText?: string;
    advertisingLabel?: string;
    iconLink?: string;
    statistics?: Array<{
        type: 'playbackStarted' | 'click';
        url: string;
    }>;
    openInBrowser?: boolean;
    iconHeight?: number;
    directLink?: boolean;
    navigationType?: string;
    description?: string;
    ageRestrictions?: string;
    /** @deprecated */
    ageRestriction?: number;
};

declare type WebViewBannerProps = {
    promoBannerProps: BannerData;
};

class WebViewBanner extends React.Component {

    public props: WebViewBannerProps;

    public constructor(props: WebViewBannerProps) {
        super(props);
    }

    public render(): JSX.Element {
        return (
            <AppRoot mode='partial'>
                <View activePanel='promo'>
                    <Panel id='promo'>
                        <FixedLayout vertical='top'>
                            <PromoBanner
                                bannerData={this.props.promoBannerProps}
                                onClose={() => console.log('onClose')}
                                isCloseButtonHidden={true}
                            />
                        </FixedLayout>
                    </Panel>
                </View>
            </AppRoot>
        );
    }
};

export = class App {

    public showBanner(promoBannerProps: any): void {
        ReactDOM.render(
            <ConfigProvider>
                <AdaptivityProvider>
                    <WebViewBanner promoBannerProps={promoBannerProps} />
                </AdaptivityProvider>
            </ConfigProvider>,
            document.getElementById('vk-container')
        );
    }

    public hideBanner(): void {
        ReactDOM.render(
            <ConfigProvider>
            </ConfigProvider>,
            document.getElementById('vk-container')
        );
    }

};
