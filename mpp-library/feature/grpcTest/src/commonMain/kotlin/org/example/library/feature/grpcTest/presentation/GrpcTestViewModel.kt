/*
 * Copyright 2022 IceRock MAG Inc. Use of this source code is governed by the Apache 2.0 license.
 */

package org.example.library.feature.grpcTest.presentation

import dev.icerock.moko.mvvm.dispatcher.EventsDispatcher
import dev.icerock.moko.mvvm.dispatcher.EventsDispatcherOwner
import dev.icerock.moko.mvvm.viewmodel.ViewModel
import kotlinx.coroutines.launch
import org.example.library.feature.grpcTest.model.GrpcTestRepository

class GrpcTestViewModel(
    override val eventsDispatcher: EventsDispatcher<EventsListener>,
    private val repository: GrpcTestRepository
) : ViewModel(), EventsDispatcherOwner<GrpcTestViewModel.EventsListener> {

    fun onMainButtonTap() {
        viewModelScope.launch {
            var message: String = ""
            try {
                message = repository.helloRequest("world")
            } catch (exc: Exception) {
                message = "Error: " + (exc.message ?: "Unknown error")
            }
            eventsDispatcher.dispatchEvent { showMessage(message) }
        }
    }

    interface EventsListener {
        fun showMessage(message: String)
    }
}
