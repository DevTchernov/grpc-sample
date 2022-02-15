/*
 * Copyright 2022 IceRock MAG Inc. Use of this source code is governed by the Apache 2.0 license.
 */

package org.example.library.feature.grpcTest.di

import dev.icerock.moko.mvvm.dispatcher.EventsDispatcher
import org.example.library.feature.grpcTest.model.GrpcTestRepository
import org.example.library.feature.grpcTest.presentation.GrpcTestViewModel

class GrpcTestFactory(
    private val repository: GrpcTestRepository
) {
    fun createViewModel(
        eventsDispatcher: EventsDispatcher<GrpcTestViewModel.EventsListener>,
    ) = GrpcTestViewModel(
        eventsDispatcher = eventsDispatcher,
        repository = repository
    )
}
